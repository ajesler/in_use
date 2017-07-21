class ThingsController < ApplicationController
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
    json_response({ message: "in use", queue_size: @thing.queued_slack_users.count })
  end

  def free
    @thing.update!(in_use: false)

    notified_user_count = NotifyQueuedUsers.for(@thing)

    json_response({ message: "free", queue_size: notified_user_count})
  end

  def slack
    slack_token = slack_params[:token]

    if !slack_token.present? || slack_token != ENV['SLACK_TOKEN']
      slack_response({ message: "the token '#{slack_token}' is not authorized" }, status: :unauthorized)
      return
    end

    slack_user = SlackUser.new(slack_params[:user_name], slack_params[:user_id])

    messages = []
    if slack_text = slack_params[:text]
      if slack_text.start_with?("help")
        messages << "Available commands are help, status, notify, and remove"
      end

      if slack_text.start_with?("notify")
        EnqueueUser.for(@thing, slack_user)
      end

      if slack_text.start_with?("queue")
        messages << "In the queue are #{@thing.queued_slack_users.pluck(:slack_user_name).join(', ')}"
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
