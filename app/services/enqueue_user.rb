class EnqueueUser
  def self.for(thing, slack_user)
    QueuedSlackUser.find_or_create_by!({
      slack_user_name: slack_user.name,
      slack_user_id: slack_user.id,
      thing_id: thing.id,
    })
  end
end
