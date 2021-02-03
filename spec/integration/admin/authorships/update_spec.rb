require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'
require 'support/poltergeist'

feature "updating an authorship via the admin interface", type: :feature, js: true do
  let!(:user) { create(:user,
                       first_name: 'Bob',
                       last_name: 'Testuser') }

  let!(:pub) { create :publication, title: "Test Publication" }

  let!(:auth) { create :authorship,
                       publication: pub,
                       user: user,
                       author_number: 5,
                       orcid_resource_identifier: nil,
                       scholarsphere_uploaded_at: Time.new(2020, 1, 22, 16, 8, 0, 0) }

  context "when the current user is an admin" do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :authorship, id: auth.id)
    end

    describe "submitting the form with new data to update an authorship record" do
      before do
        fill_in 'Orcid resource identifier', with: 'Test Orcid Resource Identifier'
        click_on 'Add a new Internal publication waiver'
        fill_in 'Reason for waiver', with: 'because'
        click_on 'Save'
      end

      it "updates the authorship's data" do
        expect(auth.reload.orcid_resource_identifier).to eq 'Test Orcid Resource Identifier'
        w = auth.waiver
        expect(w.reason_for_waiver).to eq 'because'
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.edit_path(model_name: :authorship, id: auth.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
