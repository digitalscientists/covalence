class CovalenceNotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    notification.consumer.send(notification.receiver_method,notification) if notification.consumer.respond_to? notification.receiver_method
    notification.logger.info('Notification processed! (From Notification Observer)') 
  end
end