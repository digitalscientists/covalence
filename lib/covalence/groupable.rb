require 'covalence/groupable/covalence_asset'
require 'covalence/groupable/covalence_membership'

module Covalence
  VERSION = "0.0.2"

   class Configuration
     cattr_accessor :groups
     cattr_accessor :roles
   end

   class Initializer
     def self.run configuration = Covalence::Configuration.new
       yield configuration if block_given?
     end
   end

   module Groupable
     def self.included(base)
       base.extend(ClassMethods)
     end

     module ClassMethods   
       
       def has_role?(role)
         self.roles.has_key?(role)
       end
       
       def has_roles(*roles)
         class <<self
           attr_accessor :roles
         end
         self.roles = Hash.new
         roles.each_with_index do |item, index|
           self.roles[item] = index
         end
       end
       
       def has_members(*members)
         include Covalence::Groupable::InstanceMethods
         has_many :covalence_memberships, :as => :groupable
         members.each do |member|
           has_many member, :through => :covalence_memberships, :source => :member, :source_type => member.to_s.classify do
             def remove(member)
               @owner.covalence_memberships.find_by_member_type_and_member_id(member.class.name, member.id).destroy
               @target.delete(member)
             end
           end
           member.to_s.classify.constantize.send(:has_many, :covalence_memberships, :as => :member)
           CovalenceMembership.send(:belongs_to, member, :foreign_key => 'groupable_id', :class_name => member.to_s.classify)
           member.to_s.classify.constantize.send(:has_many, self.to_s.underscore.pluralize, :through => :covalence_memberships, :source => member)
           # member.to_s.classify.constantize.send(:has_many, :groups, :through => :covalence_memberships, :source => member)
           member.to_s.classify.constantize.send(:include, Covalence::Groupable::MemberInstanceMethods)
         end
       end
     end

     module MemberInstanceMethods

       def role_in(group)
         group.class.roles.index(group.covalence_memberships.find_by_member_type_and_member_id(self.class.name, self.id))
       end
       
       def is_role(group, role)
         role == self.role_in(group)
       end
       
     end

     module InstanceMethods
       
        def members
          self.covalence_memberships.map(&:member)
        end
        
        def memberships
          self.covalence_memberships
        end
      end

   end

   module Assetable
     def self.included(base)
       base.extend(ClassMethods)
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
  
end


if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Covalence::Groupable)
  ActiveRecord::Base.send(:include, Covalence::Assetable)
  
  Rails::Initializer.run do |config|
    config.after_initialize do
      if Covalence::Configuration.groups
        Covalence::Configuration.groups.each do |group|
          begin
            groupable = group.to_s.classify.constantize
            unless groupable.roles
              class <<groupable
                attr_accessor :roles
              end
              groupable.roles = Hash.new
              Covalence::Configuration.roles.each_with_index do |item, index|
                groupable.roles[item] = index
              end
            end
          rescue
            nil
          end
        end
      end  
    end
  end
end