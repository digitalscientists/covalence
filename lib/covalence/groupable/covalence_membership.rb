class CovalenceMembership < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  belongs_to :member, :polymorphic => true
end
