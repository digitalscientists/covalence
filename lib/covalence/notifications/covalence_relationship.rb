module Covalence
  module Relationship
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        belongs_to  :parent, :polymorphic => true
        belongs_to  :child, :polymorphic => true

        validates_presence_of :parent
        validates_presence_of :child
      end
    end
  
    module ClassMethods
    
      def find_by_parent_and_child(parent, child)
        first(:conditions => [
          'parent_type = ? and parent_id =? and child_type = ? and child_id = ?',
          parent.class.to_s, 
          parent.id, 
          child.class.to_s, 
          child.id
        ])
      end
    end
    
  end
  
  module RelationshipMethods
    def self.included(base)
      base.class_eval do
        class << self
          def has_relationship relationship, options
            klass = options[:through].to_s.classify
            send(:has_many, '_'+relationship.to_s+'_with', {:as => :parent, :class_name => klass.to_s})
            send(:has_many, '_'+relationship.to_s.singularize+'_of', {:as => :child, :class_name => klass.to_s})
            send(:has_many, relationship.to_s+'_with', {:through => '_'+relationship.to_s+'_with', :source => :child, :source_type => self.to_s})
            send(:has_many_with_multiple_foreign, relationship.to_s.singularize+'_of', {:through => '_'+relationship.to_s.singularize+'_of', :source => :parent, :source_type => self.to_s, :as => [:parent, :child]})
          end
        end
      end
    end
  end
  
    
end

ActiveRecord::Base.send(:include, Covalence::RelationshipMethods)