require 'component/component_spec_helper'

describe FacultyNotificationsMailer, type: :model do
  describe '#open_access_reminder' do
    subject(:email) { FacultyNotificationsMailer.open_access_reminder(user, old_publications, new_publications) }

    let(:user) { double 'user',
                        email: 'test123@psu.edu',
                        name: 'Test User' }
    let(:old_publications) { [pub1] }
    let(:new_publications) { [pub2] }
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
        expect(body).to match 'visit the links'
      end
    end
  end

  describe '#scholarsphere_deposit_failure' do
    subject(:email) { FacultyNotificationsMailer.scholarsphere_deposit_failure(user, deposit) }

    let(:deposit) { build :scholarsphere_work_deposit, publication: pub }
    let(:pub) { build :publication,
                      scholarsphere_open_access_url: 'https://scholarsphere.test/abc123',
                      title: 'Open Access Test Publication' }
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
end
