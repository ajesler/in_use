class NotifyQueuedUsers
  def self.for(thing)
    users_to_notify = thing.queued_slack_users
    queued_user_count = users_to_notify.count

    if queued_user_count > 0
       users_to_notify.each do |user|
         other_users = users_to_notify.reject { |u| u == user }.map { |u| u.slack_user_name }
         send_notification(user, thing, other_users)
      end

      users_to_notify.destroy_all
    end

    queued_user_count
  end

  private

  def self.send_notification(user, thing, other_users)
    response = Faraday.post(ENV['SLACK_WEBHOOK_URL']) do |req|
      req.body = {
        channel: user.slack_user_id,
        text: notification_text(thing, other_users),
        as_user: false,
        username: ENV['SLACK_BOT_USERNAME'] || "ThingBot",
        icon_emoji: ENV['SLACK_BOT_EMOJI'] || ":thinking_face:",
      }.to_json
      req.headers['Content-Type'] = 'application/json'
    end

    if !response.success?
      Rails.logger.info("Failed to notify slack user #{user.slack_user_name} with #{response.status}: #{response.body}")
    end

    return response
  end

  def self.notification_text(thing, other_users)
    message = "The #{thing.name} is free"
    if other_users.present?
      message += " (notified #{other_users.join(", ")})"
    end
    message
  end
end
