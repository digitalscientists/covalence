ROOT = File.dirname(__FILE__)

# Requires
%w{rubygems test/unit mocha active_record shoulda}.each {|dependency| require dependency }
require ROOT + '/../lib/covalence'
%w{group user membership}.each { |fixture| require "fixtures/#{fixture}" }

# Setup ActiveRecord, Load schema
database_config = YAML::load_file(ROOT + '/database.yml')['sqlite3']
ActiveRecord::Base.establish_connection(database_config)
load(ROOT + '/fixtures/schema.rb')

# Tests
class UserTest < Test::Unit::TestCase
  
  context "When a user joins a group they" do
    setup do
      @user = User.create
      @group = Group.create
      @group.users << @user
    end
    
    should "be a member of that group" do
      assert @user.member_in?(@group)
    end
    
    should "have the default role" do
      assert_equal @user.role_in(@group), @group.class.default_role.to_s
    end
  end
  
end