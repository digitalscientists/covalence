require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'factory_girl'

class User
  attr_accessor :first_name
end

Factory.define :user do |f|
  f.first_name 'Foo'
end

class CovalenceTest < Test::Unit::TestCase
  context "A User" do
    setup do
      @user = Factory.build(:user)
    end

    should "have a first name" do
      assert_equal @user.first_name, 'Foo'
    end
  end
end
