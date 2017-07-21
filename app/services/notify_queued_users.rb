class NotifyQueuedUsers
  def self.for(thing)
    users_to_notify = thing.queued_slack_users
    queued_user_count = users_to_notify.count

    if queued_user_count > 0
       users_to_notify.each do |user|
        send_notification(user, thing, queued_user_count)
      end

      users_to_notify.destroy_all
    end

    queued_user_count
  end

  private

  def self.send_notification(user, thing, queue_size)
    response = Faraday.post(ENV['SLACK_WEBHOOK_URL']) do |req|
      req.body = {
        channel: user.slack_user_id,
        text: notification_text(thing, queue_size),
        as_user: false,
        username: ENV['SLACK_BOT_USERNAME'] || "ThingBot",
        icon_emoji: ENV['SLACK_BOT_EMOJI'] || ":thinking_face:",
      }.to_json
      req.headers['Content-Type'] = 'application/json'
    end

    return response
  end

  def self.notification_text(thing, queue_size)
    "The #{thing.name} is free (notifed #{pluralize(queue_size, 'person')})"
  end

  def self.pluralize(count, word)
    "#{count} #{count == 1 ? word : word.pluralize}"
  end
end
