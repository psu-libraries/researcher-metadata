require 'integration/integration_spec_helper'

feature 'Admin publication list', type: :feature do
  let!(:publication) { create(:publication) }

  context "when the current user is an admin" do
    before { authenticate_admin_user }
    it 'shows a list of the publications' do
      visit 'admin/publication'
      expect(page).to have_content 'List of Publications'
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it 'redirects back to the home page with an error message' do
      visit 'admin/publication'
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
