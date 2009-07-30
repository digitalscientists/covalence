require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_record'
require 'shoulda'
ROOT = File.dirname(__FILE__)

require ROOT + '/../lib/covalence'

schema_file = ROOT + '/fixtures/schema.rb'
database_config = YAML::load_file(ROOT + '/database.yml')['sqlite3']
ActiveRecord::Base.establish_connection(database_config)

load(schema_file)

class User < ActiveRecord::Base
  include Covalence::Member
  is_member_of :groups
end

class Group < ActiveRecord::Base
  include Covalence::Group
  has_members :users
  has_roles :member, :admin
  has_default_role :member
end

class Membership < ActiveRecord::Base
  include Covalence::Membership
end

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