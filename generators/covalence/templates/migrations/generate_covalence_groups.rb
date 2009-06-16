class GenerateCovalenceGroups < ActiveRecord::Migration
  def self.up
    create_table "covalence_relationships", :force => true do |t|
      t.string   "parent_type"
      t.integer  "parent_id"
      t.string   "child_type"
      t.integer  "child_id"
      t.string   "type"
      t.string   "state"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
   
    create_table "covalence_assets" do |t|
      t.string  "assetable_type"
      t.integer "assetable_id"
      t.integer "groupable_id"
      t.string  "groupable_type"
    end
    
    add_index :covalence_relationships, :type
    add_index :covalence_relationships, :state
    add_index :covalence_relationships, [:parent_id, :parent_type]
    add_index :covalence_relationships, [:child_id, :child_type]
    add_index :covalence_assets, [:groupable_id, :groupable_type]
    add_index :covalence_assets, [:assetable_id, :assetable_type]
    
  end
  
  def self.down
    drop_table "covalence_relationships"
    drop_table "covalence_assets"
  end
end