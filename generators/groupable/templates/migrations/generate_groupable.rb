class GenerateGroupable < ActiveRecord::Migration
  def self.up
    
    create_table "covalence_memberships" do |t|
      t.integer "member_id"
      t.string  "member_type"
      t.string  "groupable_type"
      t.integer "groupable_id"
      t.integer "role"
      t.timestamps
    end
        
    create_table "covalence_assets" do |t|
      t.string  "assetable_type"
      t.integer "assetable_id"
      t.integer "groupable_id"
      t.string  "groupable_type"
    end
    
    add_index :covalence_memberships, [:member_id, :member_type]
    add_index :covalence_memberships, [:groupable_id, :groupable_type]
    add_index :covalence_assets, [:groupable_id, :groupable_type]
    add_index :covalence_assets, [:assetable_id, :assetable_type]
  end
  
  def self.down
    drop_table "covalence_notifications"
    drop_table "covalence_relationships"
    drop_table "covalence_memberships"
    drop_table "covalence_assets"
  end
end