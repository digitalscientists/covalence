# class GenerateCovalenceNotifications < ActiveRecord::Migration
#   def self.up
#     create_table "covalence_notifications", :force => true do |t|
#       t.string   "consumer_type"
#       t.integer  "consumer_id"
#       t.string   "producer_type"
#       t.integer  "producer_id"
#       t.string   "type"
#       t.string   "state", :default => 'new'
#       t.text     "message"
#       t.datetime "created_at"
#       t.datetime "updated_at"
#       t.datetime "published_at", :default => Time.now
#     end
#     
#     add_index :covalence_notifications, [:producer_id, :producer_type]
#     add_index :covalence_notifications, [:consumer_id, :consumer_type]
#     add_index :covalence_notifications, :type
#     add_index :covalence_notifications, :state    
#   end
#   
#   def self.down
#     drop_table "covalence_notifications"
#   end
# end