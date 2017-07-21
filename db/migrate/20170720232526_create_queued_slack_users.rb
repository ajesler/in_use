class CreateQueuedSlackUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :queued_slack_users do |t|
      t.string :slack_user_name
      t.string :slack_user_id
      t.integer :thing_id

      t.timestamps
    end
  end
end
