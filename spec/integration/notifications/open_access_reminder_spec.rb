# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'sending open access reminder emails' do
  let!(:user1) { create(:user,
                        :with_psu_identity,
                        webaccess_id: 'abc123',
                        first_name: 'Tester',
                        last_name: 'Testerson') }

  let!(:membership1) { create(:user_organization_membership, user: user1, started_on: Date.new(2019, 1, 1)) }
  let!(:pub1) { create(:publication, published_on: Date.new(2020, 8, 1), title: 'Test Pub') }
  let!(:pub2) { create(:publication, published_on: Date.new(2019, 2, 1), title: 'Irrelevant Pub') }

  let!(:auth1) { create(:authorship,
                        user: user1,
                        publication: pub1,
                        confirmed: true,
                        open_access_notification_sent_at: nts) }

  let!(:auth2) { create(:authorship,
                        user: user1,
                        publication: pub2,
                        confirmed: true) }

  let!(:user2) { create(:user, :with_psu_identity, webaccess_id: 'def456', first_name: 'Other', last_name: 'User') }
  let!(:membership2) { create(:user_organization_membership, user: user2, started_on: Date.new(2019, 1, 1)) }

  let!(:u2_pub2) { create(:publication,
                          published_on: Date.new(2020, 8, 1),
                          title: 'Other Pub',
                          open_access_locations: [build(:open_access_location,
                                                        source: Source::OPEN_ACCESS_BUTTON,
                                                        url: 'a_url')]) }

  let!(:u2_auth2) { create(:authorship, user: user2, publication: u2_pub2, confirmed: true) }

  before { OpenAccessNotifier.new.send_notifications }

  context 'when notifications have not been sent about mentioned publications before' do
    let(:nts) { nil }

    it 'successfully sends a message only to applicable users' do
      open_email('abc123@psu.edu')
      expect(current_email).not_to be_nil

      open_email('def456@psu.edu')
      expect(current_email).to be_nil
    end

    it "includes the user's name in the message" do
      open_email('abc123@psu.edu')
      expect(current_email.body).to match(/Tester Testerson/)
    end

    it "shows only the list of publications that haven't been mentioned in notifications before" do
      open_email('abc123@psu.edu')
      expect(current_email.body).to match(/New publications/)
      expect(current_email.body).not_to match(/Old publications/)
    end

    it 'includes the titles of only relevant publications in the message' do
      open_email('abc123@psu.edu')
      expect(current_email.body).to match(/Test Pub/)
      expect(current_email.body).not_to match(/Irrelevant Pub/)
    end

    it 'records when the notification was sent on each authorship' do
      expect(auth1.reload.open_access_notification_sent_at).to be_within(1.minute).of(Time.current)
      expect(auth2.reload.open_access_notification_sent_at).to be_nil
    end

    context 'when done twice in immediate succession' do
      before { clear_emails }

      it 'does not send the same email twice' do
        OpenAccessNotifier.new.send_notifications

        open_email('abc123@psu.edu')
        expect(current_email).to be_nil
      end
    end
  end

  context 'when notifications have been sent about mentioned publications before' do
    let(:nts) { 1.week.ago }

    it 'shows only the list of publications that have been mentioned in notifications before' do
      open_email('abc123@psu.edu')
      expect(current_email.body).to match(/Previous publications/)
      expect(current_email.body).not_to match(/New publications/)
    end
  end
end
