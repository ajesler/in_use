class SlackResponse

  def self.for(thing)
    { attachments: [
        {
          title: usage_message(thing),
          color: thing.in_use? ? "danger" : "good",
        }
      ]
    }
  end

  private

  def self.usage_message(thing)
    "#{Time.now.to_s(:hms)}: the #{thing.name} is #{thing.in_use? ? 'in use' : 'free'}"
  end
end
