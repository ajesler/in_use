class EnqueueUser
  def self.for(thing, slack_user)
    # Should this enqueue the user even if the thing is not in use?
    QueuedSlackUser.find_or_create_by!({
      slack_user_name: slack_user.name,
      slack_user_id: slack_user.id,
      thing_id: thing.id,
    })
  end
end
