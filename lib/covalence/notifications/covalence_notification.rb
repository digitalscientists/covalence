class CovalenceNotification < ActiveRecord::Base
  belongs_to :producer, :polymorphic => true
  belongs_to :consumer, :polymorphic => true

  # validates_presence_of :flavor  # I haz a flavor
  validates_presence_of :producer
  validates_presence_of :consumer

  serialize   :message

  alias_method :synchronous_save, :save

  def self.compose args ={}
    
    producer  = args.delete(:producer)
    consumer  = args.delete(:consumer)
    type      = args.delete(:type)
    flavor    = self.to_s.underscore
    
    unless AsyncObserver::Queue.queue.nil?
      self.async_send(:create, :producer => producer, :consumer => consumer, :message => args, :flavor => flavor)
    else
      self.create(:producer => producer, :consumer => consumer, :message => args, :flavor => flavor)
    end
  end

  def composed args = {}

  end

  def save args ={}
    if defined? AsyncObserver && !AsyncObserver::Queue.queue.nil?
      self.async_send(:synchronous_save)
    else
      synchronous_save
    end
  end

  def receiver_method
    "receive_#{self.class.to_s.underscore}_notification".to_sym
  end

  def method_missing m,args=nil
    message[m.to_sym]
  end

end