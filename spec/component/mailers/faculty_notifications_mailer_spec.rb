require 'component/component_spec_helper'

describe FacultyNotificationsMailer, type: :model do

  describe '#open_access_reminder' do
    subject(:email) { FacultyNotificationsMailer.open_access_reminder(user, publications) }
    let(:user) { double 'user',
                        email: "test123@psu.edu",
                        name: "Test User" }
    let(:publications) { [pub1, pub2] }
    let(:pub1) { double 'publication 1' }
    let(:pub2) { double 'publication 2' }

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
      expect(email.subject).to eq "PSU Open Access Policy Reminder"
    end

    it "sets the correct reply-to address" do
      expect(email.reply_to).to eq ["openaccess@psu.edu"]
    end

    describe "the message body" do
      let(:body) { email.body.raw_source }

      it "mentions the user by name" do
        expect(body).to match(user.name)
      end

      xit "shows a link to manage open access info for each publication" do
      end

      xit "it shows some instructions for managing the open access info" do
      end
    end
  end
end
