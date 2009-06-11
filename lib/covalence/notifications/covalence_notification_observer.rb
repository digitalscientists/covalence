class CovalenceNotificationObserver < ActiveRecord::Observer
  
  observe :announcement
  
  def after_create(notification)
    Growler.growl("CREATED NOTIFICATION")
    notification.consumer.send(notification.receiver_method,notification) if notification.consumer.respond_to? notification.receiver_method
    notification.logger.info('Notification processed! (From Notification Observer)') 
  end
  
  def after_update
    notification.consumer.send(notification.update_receiver_method,notification) if notification.consumer.respond_to? notification.update_receiver_method
    notification.logger.info('Notification updated! (From Notification Observer)')
  end
  
  def after_find(notification)

    # Force Yaml to handle hash correctly
    if notification.message.is_a? Hash
      notification.message.each_pair do |key, value|
        if value.is_a? YAML::Object
          value.class.to_s.constantize
          notification.message[key] = YAML::load(value.to_yaml)
        end
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