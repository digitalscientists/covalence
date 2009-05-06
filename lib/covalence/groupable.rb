require 'covalence/groupable/covalence_asset'
require 'covalence/groupable/covalence_membership'

module Covalence
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
          end
        end
      end
      
      def default_role(role)
        # TODO: does not work yet
        self.class.class_eval "DEFAULT_ROLE = #{role.inspect}"
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
        membership = self.covalence_memberships.find_by_groupable_id_and_groupable_type(group.id, group.to_s)
        return membership ? membership.role : nil
      end
    end
    
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Covalence::Groupable)
end