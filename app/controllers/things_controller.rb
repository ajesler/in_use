class ThingsController < ApplicationController
  before_action :check_auth_token, except: [:slack]
  before_action :load_thing, only: [:show, :update, :slack, :in_use, :free]

  def index
    @things = Thing.all
    json_response(@things)
  end

  def show
    json_response(@thing)
  end

  def update
    @thing.update!(thing_params)
    json_response(@thing)
  end

  def in_use
    @thing.update!(in_use: true)
    @thing.usage_events.create!(event_type: Thing::IN_USE)

    json_response({ message: "in use", queue_size: @thing.queued_slack_users.count })
  end

  def free
    @thing.update!(in_use: false)
    @thing.usage_events.create!(event_type: Thing::FREE)

    notified_user_count = NotifyQueuedUsers.for(@thing)

    json_response({ message: "free", queue_size: notified_user_count})
  end

  def slack
    slack_token = slack_params[:token].try!(:strip)

    if !slack_token.present? || slack_token != ENV['SLACK_TOKEN']
      raise Unauthorized
        Rails.logger.info("Failed auth with slack token '#{slack_token}'")
        # slack_response({ message: "Unauthorized" }, status: :unauthorized)
      return
    end

    slack_user = SlackUser.new(slack_params[:user_name], slack_params[:user_id])

    messages = []
    if slack_text = slack_params[:text]
      # TODO This should be the default response of /pool
      if slack_text.start_with?("help")
        messages << <<-HELP
Available commands are help, status, notify, and remove

*help*
    show the help text

*status*
    show who is in the queue

*notify*
    add yourself to the queue to be notified when the thing becomes free

*remove*
    remove yourself from the queue
HELP
      end

      if slack_text.start_with?("notify")
        EnqueueUser.for(@thing, slack_user)
      end

      if slack_text.start_with?("queue")
        slack_users = @thing.queued_slack_users.map do |u|
          "<@#{u.slack_user_id}>"
        end

        if slack_users.count > 0
          messages << "The queue consists of #{slack_users.join(', ')}"
        else
          messages << "The queue is empty"
        end
      end

      if slack_text.start_with?("remove")
        QueuedSlackUser.where(thing: @thing, slack_user_id: slack_user.id).destroy_all
      end
    end

    response = SlackResponse.new(@thing, slack_user)
    messages.each { |m| response.add_message(m) }

    slack_response(response.to_h)
  end

  private

  def check_auth_token
    auth_token = params["token"].try!(:strip)
    if !auth_token.present? || auth_token != ENV['AUTH_TOKEN'].strip
      Rails.logger.info("Failed login with auth token '#{auth_token}'. Required token is #{ENV['AUTH_TOKEN']}")
      raise Unauthorized
    end
  rescue ActionController::ParameterMissing
    raise Unauthorized
  end

  def thing_params
    params.permit(:id, :in_use)
  end

  def slack_params
    @slack_params ||= params.permit(:id, :token, :user_id, :user_name, :command, :text)
  end

  def load_thing
    @thing = Thing.find(thing_params.require(:id))
  end
end
