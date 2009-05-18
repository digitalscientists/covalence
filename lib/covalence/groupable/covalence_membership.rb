class CovalenceMembership < CovalenceRelationship
  belongs_to :child, :polymorphic => true
  belongs_to :parent, :polymorphic => true
  
  def role
    status.to_i
  end
  
  def role=(role)
    status = role
  end
  
  def self.generate_token
    Digest::SHA1.hexdigest("--#{Time.now.utc.to_s}--")
  end

end
