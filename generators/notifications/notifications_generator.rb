class NotificationsGenerator < Rails::Generator::Base
 
  def manifest
    record do |m|
      m.migration_template "migrations/generate_notifications.rb",
                           'db/migrate',
                           :migration_file_name => "generate_notifications"
    end
  end 
end