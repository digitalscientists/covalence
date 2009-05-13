class CovalenceMembership < CovalenceRelationship
  belongs_to :child, :polymorphic => true
  belongs_to :parent, :polymorphic => true
  
  def role
    status.to_i
  end
  
  def role=(role)
    status = role
  end
end
