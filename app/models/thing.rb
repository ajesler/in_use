class Thing < ApplicationRecord
  FREE =   "free".freeze
  IN_USE = "in_use".freeze

  has_many :queued_slack_users, dependent: :destroy
  has_many :usage_events, dependent: :destroy
end
