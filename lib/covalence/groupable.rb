require 'covalence/groupable/covalence_asset'
require 'covalence/groupable/covalence_membership'

module Covalence
  
  module Assetable
    class << self
      def included base
        base.extend ClassMethods
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
    end
  end
  
  module Groupable
    class << self
      def included base
        base.extend ClassMethods
      end
    end
    
    module ClassMethods
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
    
    module GroupInstanceMethods
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
    
    module MemberInstanceMethods
      def role_in(group)
        membership = self.covalence_memberships.find_by_parent_id_and_parent_type(group.id, group.class.name)
        return membership ? membership.role : false
      end
      
      def member_in?(group)
        # if you don't know the !! is for, you probably shouldn't be here
        !!self.covalence_memberships.find_by_parent_id_and_parent_type(group.id, group.class.name)
      end
      
      def method_missing method, *args, &block
        if method.to_s =~ /^is_.*\?$/
          group = args[0]
          role = method.to_s.match(/^is_(.*)\?$/).captures[0].upcase.to_sym
          if group.has_role?(role)
            return self.role_in(group) == role
          end
        elsif method.to_s =~ /^is_.*_of$/
          role = method.to_s.match(/^is_(.*)_of$/).captures[0].upcase.to_sym
          groups = []
          klass = args[0]
          klass.all.each do |group|
            if group.has_role?(role) && self.role_in(group) == role
              groups << group
            end
          end
          return groups
        end
        super
      end
    end
    
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Covalence::Groupable)
  ActiveRecord::Base.send(:include, Covalence::Assetable)
end