require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Creating a publication", type: :feature do
  context "when the current user is an admin" do
    before do
      authenticate_admin_user
      visit rails_admin.new_path(model_name: :publication)
    end

    describe "visiting the form to create a new publication" do
      it_behaves_like "a page with the admin layout"
      it "show the correct content" do
        expect(page).to have_content "New Publication"
      end
    end

    describe "submitting the form to create a new publication" do
      before do
        fill_in 'Title', with: 'Test Publication'
        fill_in 'Secondary title', with: 'Test Subtitle'
        select 'Journal Article', from: 'Publication type'
        fill_in 'Journal title', with: 'Test Journal'
        fill_in 'Publisher', with: 'Test Publisher'
        fill_in 'Status', with: 'Test Status'
        fill_in 'Volume', with: 'Test Volume'
        fill_in 'Issue', with: 'Test Issue'
        fill_in 'Edition', with: 'Test Edition'
        fill_in 'Page range', with: 'Test Range'
        fill_in 'URL', with: 'Test URL'
        fill_in 'ISSN', with: 'Test ISSN'
        fill_in 'DOI', with: 'Test DOI'
        fill_in 'Abstract', with: 'Test Abstract'
        check 'Et al authors?'
        fill_in 'Published on', with: 'August 23, 2018'
        fill_in 'Number of citations', with: 5
        check 'Visible via API?'

        click_button 'Save'
      end

      it "creates a new publication record in the database with the provided data" do
        p = Publication.find_by(title: 'Test Publication')
        expect(p.secondary_title).to eq 'Test Subtitle'
        expect(p.publication_type).to eq 'Journal Article'
        expect(p.journal_title).to eq 'Test Journal'
        expect(p.publisher).to eq 'Test Publisher'
        expect(p.status).to eq 'Test Status'
        expect(p.volume).to eq 'Test Volume'
        expect(p.issue).to eq 'Test Issue'
        expect(p.edition).to eq 'Test Edition'
        expect(p.page_range).to eq 'Test Range'
        expect(p.url).to eq 'Test URL'
        expect(p.issn).to eq 'Test ISSN'
        expect(p.doi).to eq 'Test DOI'
        expect(p.abstract).to eq 'Test Abstract'
        expect(p.authors_et_al).to eq true
        expect(p.published_on).to eq Date.new(2018, 8, 23)
        expect(p.total_scopus_citations).to eq 5
        expect(p.visible).to eq true
      end

      it "it marks the new publication as having been manually edited" do
        p = Publication.find_by(title: 'Test Publication')
        expect(p.updated_by_user_at).not_to be_nil
      end
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.new_path(model_name: :publication)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
