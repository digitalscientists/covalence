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

    add_index :covalence_notifications, [:consumer_type, :consumer_id]
    add_index :covalence_notifications, [:producer_type, :producer_id]
    add_index :covalence_notifications, :type
    add_index :covalence_notifications, :created_at

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
    
    add_index :covalence_relationships, [:parent_type, :parent_id]
    add_index :covalence_relationships, [:child_type, :child_id]
    add_index :covalence_relationships, :type
    add_index :covalence_relationships, :state
    add_index :covalence_relationships, :created_at
    
  end
  
  def self.down
    drop_table "covalence_notifications"
    drop_table "covalence_relationships"
  end
end