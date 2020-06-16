require 'component/component_spec_helper'

describe OpenAccessNotifier do
  let(:notifier) { OpenAccessNotifier.new }
  let(:user1) { double 'user 1', potential_open_access_publications: pubs1, record_open_access_notification: nil }
  let(:user2) { double 'user 1', potential_open_access_publications: pubs2, record_open_access_notification: nil }
  let(:pubs1) { double 'publication set 1' }
  let(:pubs2) { double 'publication set 2' }
  let(:profile1) { double 'user profile 1' }
  let(:profile2) { double 'user profile 2' }
  let(:email1) { double 'email 1', deliver_now: nil }
  let(:email2) { double 'email 2', deliver_now: nil }

  describe '#send_notifications' do
    before do
      allow(User).to receive(:needs_open_access_notification).and_return([user1, user2])
      allow(UserProfile).to receive(:new).with(user1).and_return profile1
      allow(UserProfile).to receive(:new).with(user2).and_return profile2
      allow(FacultyNotificationsMailer).to receive(:open_access_reminder).with(profile1, pubs1).and_return email1
      allow(FacultyNotificationsMailer).to receive(:open_access_reminder).with(profile2, pubs2).and_return email2
    end

    it "sends a notification email to each user that needs one" do
      expect(email1).to receive(:deliver_now)
      expect(email2).to receive(:deliver_now)

      notifier.send_notifications
    end

    it "records the notification for each user" do
      expect(user1).to receive(:record_open_access_notification)
      expect(user2).to receive(:record_open_access_notification)

      notifier.send_notifications
    end
  end
end
