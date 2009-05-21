class CovalenceNotification < ActiveRecord::Base
  
  belongs_to :producer, :polymorphic => true
  belongs_to :consumer, :polymorphic => true

  validates_presence_of :producer
  validates_presence_of :consumer

  serialize   :message

  # alias_method :synchronous_save, :save

  def composed args = {}

  end
  
  def self.is_not_persistent
    self.to_s.constantize.send(:cattr_accessor, :persistence)
    self.to_s.constantize.persistence = false
  end
  
  def persistent?
    !self.class.respond_to?(:persistence) || self.class.persistence
  end

  def after_find
    unless persistent?
      self.destroy
    else
      if self.state == 'new'
        self.update_attribute('state', 'read')
      end
    end
  end

  # def save args ={}
  #     if defined? AsyncObserver && !AsyncObserver::Queue.queue.nil?
  #       self.async_send(:synchronous_save)
  #     else
  #       synchronous_save
  #     end
  #   end

  def receiver_method
    "receive_#{self.class.to_s.underscore}_notification".to_sym
  end

  # def method_missing m,args=nil
  #     message[m.to_sym]
  #   end

end