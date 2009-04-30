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

       def has_members(*members)
         include InstanceMethods
         has_many :covalence_memberships, :as => :groupable
         members.each do |member|
           has_many member, :through => :covalence_memberships, :source => :member, :source_type => member.to_s.classify do
             def remove(member)
               @owner.covalence_memberships.find_all_by_member_type_and_member_id(member.class.name, member.id).map(&:destroy)
               @target.delete(member)
             end
           end
           member.to_s.classify.constantize.send(:has_many, :covalence_memberships, :as => :member)
           member.to_s.classify.constantize.send(:has_many, :groups, :through => :covalence_memberships)
         end
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
          rescue
            nil
          end
        end
      end  
    end
  end
end