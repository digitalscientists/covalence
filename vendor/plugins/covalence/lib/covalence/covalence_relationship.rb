class CovalenceRelationship < ActiveRecord::Base
    belongs_to  :parent, :polymorphic => true
    belongs_to  :child, :polymorphic => true

    # validates_presence_of :flavor  # I haz a flavor
    validates_presence_of :state  
    validates_presence_of :parent
    validates_presence_of :child
end