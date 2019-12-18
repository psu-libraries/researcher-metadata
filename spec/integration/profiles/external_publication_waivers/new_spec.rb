require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "visiting the page to submit an open access waiver for a publication that is not in the database" do
  let(:user) { create :user }

  context "when the user is not signed in" do
    before { visit new_external_publication_waiver_path }

    it "does not allow them to visit the page" do
      expect(page.current_path).not_to eq new_external_publication_waiver_path
    end
  end


  context "when the user is signed in" do
    before do 
      authenticate_as(user)
      visit new_external_publication_waiver_path
    end

    it_behaves_like "a profile management page"
  end
end
