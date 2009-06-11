module Covalence
  module Notification
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        belongs_to :producer, :polymorphic => true
        belongs_to :consumer, :polymorphic => true
        after_save :check_consumer
        validates_presence_of :producer
        validates_presence_of :consumer
        serialize :message
      end
    end
        
    def persistent?
      !self.class.respond_to?(:persistence) || self.class.persistence
    end

    def receiver_method
      "receive_#{self.class.to_s.underscore}_notification".to_sym
    end

    def update_receiver_method
      "receive_#{self.class.to_s.underscore}_notification_update".to_sym
    end
      
    def check_consumer
      Growler.growl("CREATED NOTIFICATION")
      consumer.send(receiver_method, self) if consumer.respond_to? receiver_method
      logger.info('Notification processed! (From Notification Observer)') 
    end
        
    module ClassMethods
      
      def is_not_persistent
        self.to_s.constantize.send(:cattr_accessor, :persistence)
        self.to_s.constantize.persistence = false
      end
      
    end
  end
end