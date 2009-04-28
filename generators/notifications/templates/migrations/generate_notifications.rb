class GenerateCovalence < ActiveRecord::Migration
  def self.up
    create_table "covalence_notifications", :force => true do |t|
      t.string   "consumer_type"
      t.integer  "consumer_id"
      t.string   "producer_type"
      t.integer  "producer_id"
      t.string   "type"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "covalence_relationships", :force => true do |t|
      t.string   "parent_type"
      t.integer  "parent_id"
      t.string   "child_type"
      t.integer  "child_id"
      t.string   "type"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
  
  def self.down
    drop_table "covalence_notifications"
    drop_table "covalence_relationships"
    drop_table "covalence_memberships"
    drop_table "covalence_assets"
  end
end