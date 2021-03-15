require 'component/component_spec_helper'

describe OpenAccessNotifier do
  let(:notifier) { OpenAccessNotifier.new(user_collection) }
  let(:user1) { double 'user 1',
                       old_potential_open_access_publications: pubs1,
                       new_potential_open_access_publications: pubs2,
                       record_open_access_notification: nil }
  let(:user2) { double 'user 2',
                       old_potential_open_access_publications: pubs3,
                       new_potential_open_access_publications: pubs4,
                       record_open_access_notification: nil }
  let(:user_collection) { double 'user collection', needs_open_access_notification: [user1, user2] }
  let(:pubs1) { [pub1] }
  let(:pubs2) { [pub2] }
  let(:pubs3) { [pub3] }
  let(:pubs4) { [pub4] }
  let(:profile1) { double 'user profile 1' }
  let(:profile2) { double 'user profile 2' }
  let(:email1) { double 'email 1', deliver_now: nil }
  let(:email2) { double 'email 2', deliver_now: nil }
  let(:pub1) { double 'publication 1', authorships: pub1_auths }
  let(:pub2) { double 'publication 2', authorships: pub2_auths }
  let(:pub3) { double 'publication 3', authorships: pub3_auths }
  let(:pub4) { double 'publication 4', authorships: pub4_auths }
  let(:pub1_auths) { double 'auth set 1' }
  let(:pub2_auths) { double 'auth set 2' }
  let(:pub3_auths) { double 'auth set 3' }
  let(:pub4_auths) { double 'auth set 4' }
  let(:auth1) { double 'authorship 1', record_open_access_notification: nil }
  let(:auth2) { double 'authorship 2', record_open_access_notification: nil }
  let(:auth3) { double 'authorship 3', record_open_access_notification: nil }
  let(:auth4) { double 'authorship 4', record_open_access_notification: nil }

  describe '#send_notifications' do
    before do
      allow(UserProfile).to receive(:new).with(user1).and_return profile1
      allow(UserProfile).to receive(:new).with(user2).and_return profile2
      allow(FacultyNotificationsMailer).to receive(:open_access_reminder).with(profile1, pubs1, pubs2).and_return email1
      allow(FacultyNotificationsMailer).to receive(:open_access_reminder).with(profile2, pubs3, pubs4).and_return email2
      allow(pub1_auths).to receive(:find_by).with(user: user1).and_return auth1
      allow(pub2_auths).to receive(:find_by).with(user: user1).and_return auth2
      allow(pub3_auths).to receive(:find_by).with(user: user2).and_return auth3
      allow(pub4_auths).to receive(:find_by).with(user: user2).and_return auth4
      allow(EmailError).to receive(:create!)
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

    it "records the notification for each authorship" do
      expect(auth1).to receive(:record_open_access_notification)
      expect(auth2).to receive(:record_open_access_notification)
      expect(auth3).to receive(:record_open_access_notification)
      expect(auth4).to receive(:record_open_access_notification)

      notifier.send_notifications
    end

    context "when an error is raised while sending an email" do
      before { allow(FacultyNotificationsMailer).to receive(:open_access_reminder).with(profile1, pubs1, pubs2).and_raise Net::SMTPFatalError.new("The error message") }

      it "sends emails that don't raise errors" do
        expect(email2).to receive(:deliver_now)

        notifier.send_notifications
      end

      it "records only the successful notifications" do
        expect(user1).not_to receive(:record_open_access_notification)
        expect(user2).to receive(:record_open_access_notification)

        notifier.send_notifications
      end

      it "records only the successful notifications for each authorship" do
        expect(auth1).not_to receive(:record_open_access_notification)
        expect(auth2).not_to receive(:record_open_access_notification)
        expect(auth3).to receive(:record_open_access_notification)
        expect(auth4).to receive(:record_open_access_notification)

        notifier.send_notifications
      end

      it "records the error" do
        expect(EmailError).to receive(:create!).with(message: 'The error message', user: user1)

        notifier.send_notifications
      end
    end
  end
end
