require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "updating a publication via the admin interface", type: :feature do
  let!(:pub) { create(:publication,
                      title: "Test Publication",
                      scholarsphere_open_access_url: 'existing_scholarsphere_url') }

  context "when the current user is an admin" do
    before do
      authenticate_admin_user
      visit rails_admin.edit_path(model_name: :publication, id: pub.id)
    end

    describe "viewing the form" do
      it "does not allow the total Scopus citations to be set" do
        expect(page).not_to have_field "Total scopus citations"
      end
    end

    describe "submitting the form with new data to update a publication record" do
      before do
        fill_in 'Title', with: 'Updated Title'
        fill_in 'Scholarsphere Open Access URL', with: 'new_scholarsphere_url'
        click_on 'Save'
      end

      it "updates the publication's data" do
        expect(pub.reload.title).to eq 'Updated Title'
        expect(pub.reload.scholarsphere_open_access_url).to eq 'new_scholarsphere_url'
      end

      it "sets the timestamp on the publication to indicate that it was manually updated" do
        expect(pub.reload.updated_by_user_at).not_to be_blank
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.edit_path(model_name: :publication, id: pub.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end