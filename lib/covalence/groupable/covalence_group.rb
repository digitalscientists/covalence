module Covalence

  module Group
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        include Covalence::Assetable
      end
    end
    
    module ClassMethods
      
      def has_group_assets(*assets)
        has_many :covalence_assets, :as => :groupable
        assets.each do |asset|
          has_many asset, :through => :covalence_assets, :source => :assetable, :source_type => asset.to_s.classify
          asset.to_s.classify.constantize.send(:has_many, :covalence_assets, :as => :assetable)
          asset.to_s.classify.constantize.send(:has_many, :groups, :through => :covalence_assets)
        end
      end
      
      def has_members *members
        include Covalence::Groupable::GroupInstanceMethods
        has_many :covalence_memberships, :as => :parent 
        members.each do |member|
          has_many member, :through => :covalence_memberships, :source => 'child', :source_type => member.to_s.classify do
            
            def <<(*args)
              args.each do |arg|
                create_with_role(arg, nil)
              end
            end
            
            def remove(member)
              @owner.covalence_memberships.find_by_child_type_and_child_id(member.class.name, member.id).destroy
              @target.delete(member)
            end
            
            def create_with_role(member, role)
              if role != nil
                @owner.covalence_memberships.create(:child => member, :status => role.to_s)
              elsif @owner.class.respond_to?(:default_role)
                @owner.covalence_memberships.create(:child => member, :status => @owner.class.default_role.to_s)
              end
            end
            
                        
            def join(member, role = nil)
              create_with_role(member, role)
            end
          end
        end
      end
      
      def has_default_role(role)
        # TODO: does not work yet
        class << self
          attr_accessor :default_role
        end
        @default_role = role
      end
      
      def is_member_of *groups
        include Covalence::Groupable::MemberInstanceMethods
        has_many :covalence_memberships, :as => :child
        groups.each do |group|
          has_many group, :through => :covalence_memberships, :source => 'parent', :source_type => group.to_s.classify, :conditions => ['state is null or state != ?', 'pending']
        end
      end
      
      def has_roles *roles
        class << self
          attr_accessor :roles
        end
        self.roles = roles
      end
    end
  
    def has_role?(role)
      self.class.roles.include?(role)
    end
    
    def members
      self.covalence_memberships.map(&:child)
    end
    
    def memberships
      self.covalence_memberships
    end
    
    def with_role(role)
      self.covalence_memberships.all(:conditions => ['status = ?', role.to_s]).map(&:child)
    end
  end
end