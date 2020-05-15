require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "submitting an open access waiver for a publication that is not in the database" do
  let(:user) { create :user,
                      webaccess_id: 'test123',
                      first_name: 'Test',
                      last_name: 'User' }
  before do 
    authenticate_as(user)
    visit new_external_publication_waiver_path
  end

  context "successfully submitting the form" do
    before do
      fill_in "Publication Title", with: "My Test Publication"
      fill_in "Reason for waiver", with: "Because."
      fill_in "Abstract", with: "The abstract text."
      fill_in "Digital Object Identifier (DOI)", with: "https://doi.org/the-doi"
      fill_in "Journal", with: "Test Journal"
      fill_in "Publisher", with: "Test Publisher"
      click_button "Submit"
    end

    it "saves the submitted data" do
      w = ExternalPublicationWaiver.find_by(publication_title: "My Test Publication")

      expect(w.reason_for_waiver).to eq "Because."
      expect(w.abstract).to eq "The abstract text."
      expect(w.doi).to eq "https://doi.org/the-doi"
      expect(w.journal_title).to eq "Test Journal"
      expect(w.publisher).to eq "Test Publisher"
    end

    it "redirects back to the publication list" do
      expect(page.current_path).to eq edit_profile_publications_path
    end

    it "shows a success message" do
      expect(page).to have_content I18n.t('profile.external_publication_waivers.create.success')
    end

    it "sends a confirmation email to the user" do
      open_email('test123@psu.edu')
      expect(current_email).not_to be_nil
      expect(current_email.subject).to match(/open access waiver confirmation/i)
      expect(current_email.body).to match(/Test User/)
      expect(current_email.body).to match(/My Test Publication/)
    end
  end

  context "submitting the form with errors" do
    before do
      fill_in "Publication Title", with: "My Test Publication"
      fill_in "Reason for waiver", with: "Because."
      click_button "Submit"
    end

    it "does not save the waiver data" do
      expect(ExternalPublicationWaiver.find_by(publication_title: "My Test Publication")).to be_nil
    end

    it "rerenders the form" do
      expect(page.current_path).to eq external_publication_waivers_path
      expect(page.find_field("Reason for waiver").value).to eq "Because."
    end

    it "shows an error message" do
      expect(page).to have_content "Validation failed: Journal title can't be blank"
    end
  end
end
