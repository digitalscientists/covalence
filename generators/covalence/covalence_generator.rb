class CovalenceGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      type = args[0] || nil
      m.migration_template "migrations/generate_covalence_groups.rb", 'db/migrate', :migration_file_name => "generate_covalence_groups" unless type == 'notifications'
      m.migration_template "migrations/generate_covalence_notifications.rb", 'db/migrate', :migration_file_name => "generate_covalence_notifications" unless type == 'groups'      
    end    
  end 
end