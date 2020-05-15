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
      expect(email.from).to eq ["no-reply@example.com"]
    end

    it "sends the email with the correct subject" do
      expect(email.subject).to eq "open access waiver confirmation"
    end

    describe "the message body" do
      let(:body) { email.body.raw_source }

      it "mentions the User by name" do
        expect(body).to match(user.name)
      end

      it "lists the publication title" do
        expect(body).to match("Test Pub")
      end

      it "lists the journal name" do
        expect(body).to match("Test Journal")
      end

      context "when the waiver has no DOI" do
        before { waiver.doi = "" }

        it "does not mention a DOI" do
          expect(body).not_to match(/DOI/i)
        end
      end

      context "when the waiver has a DOI" do
        before { waiver.doi = "test-digital-object-identifier" }

        it "lists the DOI" do
          expect(body).to match("test-digital-object-identifier")
        end
      end

      context "when the waiver has no publisher" do
        before { waiver.publisher = "" }

        it "does not mention a publisher" do
          expect(body).not_to match(/publisher/i)
        end
      end

      context "when the waiver has a publisher" do
        before { waiver.publisher = "Test Publisher" }

        it "lists the publisher" do
          expect(body).to match("Test Publisher")
        end
      end

      context "when the waiver has no reason" do
        before { waiver.reason_for_waiver = "" }

        it "does not mention a reason" do
          expect(body).not_to match(/reason/i)
        end
      end

      context "when the waiver has a reason" do
        before { waiver.reason_for_waiver = "The reason" }

        it "lists the reason" do
          expect(body).to match("The reason")
        end
      end
    end
  end
end
