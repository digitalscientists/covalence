class CovalenceGenerator < Rails::Generator::Base
 
  def manifest
    record do |m|
      m.migration_template "migrations/generate_covalence.rb",
                           'db/migrate',
                           :migration_file_name => "generate_covalence"
    end
  end 
end