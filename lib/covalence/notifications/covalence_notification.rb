class CovalenceNotification < ActiveRecord::Base
  
  belongs_to :producer, :polymorphic => true
  belongs_to :consumer, :polymorphic => true

  validates_presence_of :producer
  validates_presence_of :consumer

  serialize :message

  #alias_method :synchronous_save, :save
  

  def composed args = {}
    # Not implemented
  end
  
  def self.is_not_persistent
    self.to_s.constantize.send(:cattr_accessor, :persistence)
    self.to_s.constantize.persistence = false
  end
  
  def persistent?
    !self.class.respond_to?(:persistence) || self.class.persistence
  end

  def receiver_method
    "receive_#{self.class.to_s.underscore}_notification".to_sym
  end

end