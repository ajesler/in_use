class Thing < ApplicationRecord
  has_many :queued_slack_users, dependent: :destroy
end
