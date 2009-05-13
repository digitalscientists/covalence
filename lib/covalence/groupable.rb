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
        has_many :covalence_memberships, :as => :groupable 
        members.each do |member|
          has_many member, :through => :covalence_memberships, :source => 'member', :source_type => member.to_s.classify do
            def remove(member)
              @owner.covalence_memberships.find_by_member_type_and_member_id(member.class.name, member.id).destroy
              @target.delete(member)
            end
            
            def join(member, role = nil)
              self << member
              if role
                case role
                  when Symbol then role_id = @owner.class.roles.index(role)
                  else role_id = role
                end
                @owner.covalence_memberships.find_by_member_type_and_member_id(member.class.name, member.id).update_attribute("role", role_id)
              else
                
              end
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
        has_many :covalence_memberships, :as => :member
        groups.each do |group|
          has_many group, :through => :covalence_memberships, :source => 'groupable', :source_type => group.to_s.classify
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
        self.covalence_memberships.map(&:member)
      end
      
      def memberships
        self.covalence_memberships
      end
    end
    
    module MemberInstanceMethods
      def role_in(group)
        membership = self.covalence_memberships.find_by_groupable_id_and_groupable_type(group.id, group.class.name)
        return membership ? group.class.roles[membership.role] : nil
      end
      
      def method_missing method, *args, &block
        if method.to_s =~ /is_.*\?/
          group = args[0]
          role = method.to_s.match(/is_(.*)\?/).captures[0].upcase.to_sym
          if group.has_role?(role.to_sym)
            return self.role_in(group) == role
          end
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