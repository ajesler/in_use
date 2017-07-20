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
    json_response({ message: "in use" })
  end

  def free
    @thing.update!(in_use: false)
    json_response({ message: "free" })
  end

  def slack
    slack_token = params["token"]
    if slack_token != ENV['SLACK_TOKEN']
      slack_response({ message: "the token '#{slack_token}' is not authorized" }, status: :unauthorized)
      return
    end

    in_use = @thing.in_use?
    slack_response({
      attachments: [
        {
          title: "The #{@thing.name} is #{"not " if !in_use}in use",
          color: in_use ? "danger" : "good",
        }
      ]
    })
  end

  private

  def thing_params
    params.permit(:id, :in_use)
  end

  def load_thing
    @thing = Thing.find(thing_params.require(:id))
  end
end
