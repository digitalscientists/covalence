module Covalence
  module Associations
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def has_many_with_multiple_foreign(association_id, options = {}, &extension)
        reflection = create_has_many_reflection(association_id, options, &extension)
        configure_dependency_for_has_many(reflection)
        add_association_callbacks(reflection.name, reflection.options)

        if options[:through]
          collection_accessor_methods(reflection, HasManyThroughWithMultipleForeignAssociation)
        else
          collection_accessor_methods(reflection, HasManyAssociation)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Covalence::Associations)