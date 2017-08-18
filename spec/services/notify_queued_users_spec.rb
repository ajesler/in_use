require 'rails_helper'

describe NotifyQueuedUsers do
  describe ".notification_text" do
    let(:thing) { double(Thing, name: "table") }
    let(:notification_text) { NotifyQueuedUsers.notification_text(thing, other_users) }
    let(:other_users) { [] }

    context "when there are no other users in the queue" do
      it "only includes the free message" do
        expect(notification_text).to eq "The table is free"
      end
    end

    context "when there are multiple users in the queue" do
      let(:other_users) { [ "u1", "u2", "u3" ] }
      it "shows who" do
        expect(notification_text).to eq "The table is free (notified u1, u2, u3)"
      end
    end
  end
end
