module Covalence
  
  module Member
    def self.included(model)
      model.extend(ClassMethods)
    end
     
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