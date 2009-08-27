require 'covalence/notifications'
require 'covalence/groups'
require 'covalence/has_many_through_with_multiple_foreign_asssociation'

module Covalence
  class << self
    def enable
      enable_actionpack
    end
    
    def enable_actionpack
      require 'covalence/view_helpers'
      ActionView::Base.send :include, ViewHelpers
    end
  end
end

if defined?(Rails) and defined?(ActiveRecord) and defined?(ActionController)
  Covalence.enable
end