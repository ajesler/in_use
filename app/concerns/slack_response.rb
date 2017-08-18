class SlackResponse
  attr_reader :thing, :slack_user

  def initialize(thing, slack_user)
    @thing = thing
    @slack_user = slack_user
    @messages = []
    @fields = []
  end

  def add_message(message)
    @messages << message
  end

  def to_h
    if thing.in_use?
      @fields << { title: "Queue Size", short: true, value: thing.queued_slack_users.count }
      @fields << { title: "In Queue", short: true, value: user_in_queue_text }
    end

    {
      username: ENV['SLACK_BOT_USERNAME'] || "ThingBot",
      icon_emoji: ENV['SLACK_BOT_EMOJI'] || ":thinking_face:",
      attachments: [
        {
          title: title,
          text: @messages.to_sentence,
          color: thing.in_use? ? "danger" : "good",
          fields: @fields,
          mrkdwn_in: ["text"],
        }
      ]
    }
  end

  private

  def user_in_queue_text
    in_queue = thing.queued_slack_users.any? { |u| u.slack_user_id == slack_user.id }
    in_queue ? "yes" : "no"
  end

  def title
    "#{Time.now.to_s(:hms)} | the #{thing.name} is #{thing.in_use? ? 'in use' : 'free'}. "
  end
end
