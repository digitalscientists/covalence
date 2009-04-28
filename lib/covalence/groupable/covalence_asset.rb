class CovalenceAsset < ActiveRecord::Base
  belongs_to :assetable, :polymorphic => true
  belongs_to :groupable, :polymorphic => true
end