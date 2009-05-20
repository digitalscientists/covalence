class CovalenceNotification < ActiveRecord::Base
  
  cattr_accessor :persistent
  
  belongs_to :producer, :polymorphic => true
  belongs_to :consumer, :polymorphic => true

  validates_presence_of :producer
  validates_presence_of :consumer

  serialize   :message

  # alias_method :synchronous_save, :save

  def composed args = {}

  end
  
  def self.is_not_persistent
    self.persistent = false
  end

  def after_find
    if persistent == false
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