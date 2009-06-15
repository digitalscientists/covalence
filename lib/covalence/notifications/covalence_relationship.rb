class CovalenceRelationship < ActiveRecord::Base
    belongs_to  :parent, :polymorphic => true
    belongs_to  :child, :polymorphic => true

    # validates_presence_of :flavor  # I haz a flavor
    validates_presence_of :parent
    validates_presence_of :child
    
    def self.find_by_parent_and_child(parent, child)
      Growler.growl(parent.class)
      first(:conditions => [
        'parent_type = ? and parent_id =? and child_type = ? and child_id = ?',
        parent.class.to_s, 
        parent.id, 
        child.class.to_s, 
        child.id
      ])
    end
    
end