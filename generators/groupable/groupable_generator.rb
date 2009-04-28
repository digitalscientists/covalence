class GroupableGenerator < Rails::Generator::Base
 
  def manifest
    record do |m|
      m.migration_template "migrations/generate_groupable.rb",
                           'db/migrate',
                           :migration_file_name => "generate_groupable"
    end
  end 
end