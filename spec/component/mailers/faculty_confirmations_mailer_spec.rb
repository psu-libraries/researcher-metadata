require 'component/component_spec_helper'

describe FacultyConfirmationsMailer, type: :model do

  describe '#open_access_waiver_confirmation' do
    subject(:email) { FacultyConfirmationsMailer.open_access_waiver_confirmation(user, waiver) }
    let(:user) { double 'user',
                        email: "test123@psu.edu",
                        name: "Test User" }
    let(:waiver) { build :external_publication_waiver,
                         publication_title: "Test Pub",
                         journal_title: "Test Journal" }

    before do
      allow(ActionMailer::Base).to receive(:default_url_options).and_return({host: "example.com"})
    end

    it "sends the email to the given user's email address" do
      expect(email.to).to eq ["test123@psu.edu"]
    end

    it "sends the email from the correct address" do
      expect(email.from).to eq ["openaccess@psu.edu"]
    end

    it "sends the email with the correct subject" do
      expect(email.subject).to eq "PSU Open Access Policy Waiver for Requested Article"
    end

    it "sets the correct reply-to address" do
      expect(email.reply_to).to eq ["openaccess@psu.edu"]
    end

    describe "the message body" do
      let(:body) { email.body.raw_source }

      it "mentions the User by name" do
        expect(body).to match(user.name)
      end

      it "mentions the publication title" do
        expect(body).to match("Test Pub")
      end

      it "mentions the journal name" do
        expect(body).to match("Test Journal")
      end

      it "mentions the name of the open access policy" do
        expect(body).to match("AC02")
      end

      it "shows a link to Scholarsphere" do
        expect(body).to match("https://scholarsphere.psu.edu/")
      end

      it "shows a contact link" do
        expect(body).to match("https://libraries.psu.edu/services/scholarly-publishing-services/contact-copyright-publishing-and-open-access")
      end
    end
  end
end
