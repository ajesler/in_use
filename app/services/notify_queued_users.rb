class NotifyQueuedUsers
  def self.for(thing)
    users_to_notify = thing.queued_slack_users
    queued_user_count = users_to_notify.count

    if queued_user_count > 0
      client = Slack::Web::Client.new

      users_to_notify.each do |user|
        send_notification(client, user, thing, queued_user_count)
      end

      users_to_notify.destroy_all
    end

    queued_user_count
  end

  private

  def self.send_notification(client, user, thing, queue_size)
    client.chat_postMessage({
      channel: user.slack_user_id,
      text: notification_text(thing, queue_size),
      as_user: false
    })
  end

  def self.notification_text(thing, queue_size)
    "The #{thing.name} is free (notifed #{pluralize(queue_size, 'person')})"
  end

  def self.pluralize(count, word)
    "#{count} #{count == 1 ? word : word.pluralize}"
  end
end
