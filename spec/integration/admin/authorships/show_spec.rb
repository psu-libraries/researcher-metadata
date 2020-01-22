require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin authorship detail page", type: :feature do
  let!(:user) { create(:user,
                       first_name: 'Bob',
                       last_name: 'Testuser') }

  let!(:pub) { create :publication, title: "A Test Publication" }

  let!(:auth) { create :authorship,
                       publication: pub,
                       user: user,
                       author_number: 5,
                       scholarsphere_uploaded_at: Time.new(2020, 1, 22, 16, 8, 0, 0) }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :authorship, id: auth.id) }

      it "shows the authorship detail heading" do
        expect(page).to have_content "Details for Authorship 'Authorship ##{auth.id}'"
      end

      it "shows a link to the authorship's publication" do
        expect(page).to have_link "A Test Publication", href: rails_admin.show_path(model_name: :publication, id: pub.id)
      end

      it "shows a link to the authorship's user" do
        expect(page).to have_link "Bob Testuser", href: rails_admin.show_path(model_name: :user, id: user.id)
      end

      it "shows the authorship's author number" do
        expect(page).to have_content "5"
      end

      it "shows the authorship's ScholarSphere upload timestamp" do
        expect(page).to have_content "January 22, 2020 16:08"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :authorhsip, id: auth.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :authorship, id: auth.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
