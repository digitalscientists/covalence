class CovalenceNotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    notification.consumer.send(notification.receiver_method,notification) if notification.consumer.respond_to? notification.receiver_method
    notification.logger.info('Notification processed! (From Notification Observer)') 
  end
  
  def after_find(notification)

    # YAML CAN SUCK ON THIS
    notification.message.each_pair do |key, value|
      if value.is_a? YAML::Object
        value.class.to_s.constantize
        notification.message[key] = YAML::load(value.to_yaml)
      end
    end
    
    unless notification.persistent?
      notification.destroy
    else
      if notification.state == 'new'
        notification.update_attribute('state', 'read')
      end
    end
  end
end