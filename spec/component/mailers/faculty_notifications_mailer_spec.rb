# frozen_string_literal: true

require 'component/component_spec_helper'

describe FacultyNotificationsMailer, type: :model do
  describe '#open_access_reminder' do
    subject(:email) { described_class.open_access_reminder(user, [pub1, pub2]) }

    let(:user) { double 'user',
                        email: 'test123@psu.edu',
                        name: 'Test User' }
    let(:pub1) { double 'publication 1', to_param: '1', title: 'Test Pub One' }
    let(:pub2) { double 'publication 2', to_param: '2', title: 'Test Pub Two' }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it "sends the email to the given user's email address" do
      expect(email.to).to eq ['test123@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'Penn State Open Access Policy: Articles to Upload'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'mentions the user by name' do
        expect(body).to match(user.name)
      end

      it 'shows a link to manage open access info for each publication' do
        expect(body).to match %{<a href="http://example.com/profile/publications/1/open_access/edit">Test Pub One</a>}
        expect(body).to match %{<a href="http://example.com/profile/publications/2/open_access/edit">Test Pub Two</a>}
      end

      it 'shows some instructions for managing the open access info' do
        expect(body).to match "Please click the publication"
      end
    end
  end

  describe '#scholarsphere_deposit_failure' do
    subject(:email) { described_class.scholarsphere_deposit_failure(user, deposit) }

    let(:deposit) { build(:scholarsphere_work_deposit, publication: pub) }
    let(:pub) { build(:publication,
                      open_access_locations: [
                        build(:open_access_location, :scholarsphere, url: 'https://scholarsphere.test/abc123')
                      ],
                      title: 'Open Access Test Publication') }
    let(:user) { double 'user',
                        email: 'test123@psu.edu',
                        name: 'Test User' }

    it "sends the email to the given user's email address" do
      expect(email.to).to eq ['test123@psu.edu']
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['scholarsphere@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'Your publication could not be deposited in ScholarSphere'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['scholarsphere@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'mentions the user by name' do
        expect(body).to match(user.name)
      end

      it 'mentions the publication title' do
        expect(body).to match('Open Access Test Publication')
      end
    end
  end

  describe '#wrong_file_version' do
    subject(:email) { described_class.wrong_file_version(publications) }

    let(:user) { create(:user) }
    let!(:aif1) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        version: 'acceptedVersion',
        user_id: user.id
      )
    }
    let!(:aif2) {
      create(
        :activity_insight_oa_file,
        publication: pub2,
        version: 'acceptedVersion',
        user_id: user.id
      )
    }
    let(:publications) { [pub1, pub2] }
    let(:pub1) { create(:publication, title: 'Test Pub One', preferred_version: 'publishedVersion') }
    let(:pub2) { create(:publication, title: 'Test Pub Two', preferred_version: 'publishedVersion') }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it "sends the email to the given user's email address" do
      expect(email.to).to eq ["#{user.webaccess_id}@psu.edu"]
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'Open Access Post-Print Publication Files in Activity Insight'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'shows a link to manage open access info for each publication' do
        expect(body).to match %{<a href="https://metadata.libraries.psu.edu/profile/publications/edit">Manage Profile Publications</a>}
      end

      it 'shows the correct table headers' do
        expect(body).to match('Title')
        expect(body).to match('Version we have')
        expect(body).to match('Version that can be deposited')
      end

      it 'mentions the publication title' do
        expect(body).to match('Test Pub One')
      end
    end
  end

  describe '#preferred_file_version_none' do
    subject(:email) { described_class.preferred_file_version_none(publications) }

    let(:user) { create(:user) }
    let!(:aif1) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        version: 'acceptedVersion',
        user_id: user.id
      )
    }
    let!(:aif2) {
      create(
        :activity_insight_oa_file,
        publication: pub2,
        version: 'acceptedVersion',
        user_id: user.id
      )
    }
    let(:publications) { [pub1, pub2] }
    let(:pub1) { create(:publication, title: 'Test One', preferred_version: 'None') }
    let(:pub2) { create(:publication, title: 'Test Two', preferred_version: 'None') }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({ host: 'example.com' })
    end

    it "sends the email to the given user's email address" do
      expect(email.to).to eq ["#{user.webaccess_id}@psu.edu"]
    end

    it 'sends the email from the correct address' do
      expect(email.from).to eq ['openaccess@psu.edu']
    end

    it 'sends the email with the correct subject' do
      expect(email.subject).to eq 'Open Access Post-Print Publication Files in Activity Insight'
    end

    it 'sets the correct reply-to address' do
      expect(email.reply_to).to eq ['openaccess@psu.edu']
    end

    describe 'the message body' do
      let(:body) { email.body.raw_source }

      it 'shows a link to manage open access info for each publication' do
        expect(body).to match %{<a href="https://metadata.libraries.psu.edu/profile/publications/edit">Manage Profile Publications</a>}
      end

      it 'mentions the publication title' do
        expect(body).to match('Test One')
        expect(body).to match('Test Two')
      end
    end
  end
end
