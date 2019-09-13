require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin publication detail page", type: :feature do
  let!(:user1) { create(:user,
                        first_name: 'Bob',
                        last_name: 'Testuser') }
  let!(:user2) { create(:user,
                        first_name: 'Susan',
                        last_name: 'Tester') }

  let!(:pub) { create :publication,
                      title: "Bob's Publication",
                      journal_title: "Prestigious Journal",
                      publisher: "The Publisher",
                      published_on: Date.new(2017, 1, 1),
                      publication_type: "Academic Journal Article",
                      status: "Published",
                      volume: "27",
                      issue: "39",
                      edition: "14",
                      page_range: "12-15",
                      issn: "1234-5678",
                      doi: "https://example.doi.org/test",
                      published_on: Date.new(2018, 8, 1) }

  let!(:auth1) { create :authorship,
                        publication: pub,
                        user: user1 }

  let!(:auth2) { create :authorship,
                        publication: pub,
                        user: user2 }

  let!(:con1) { create :contributor,
                       publication: pub,
                       first_name: "Jill",
                       last_name: "Author" }

  let!(:con2) { create :contributor,
                       publication: pub,
                       first_name: "Jack",
                       last_name: "Contributor" }

  let!(:imp1) { create :publication_import,
                       publication: pub }

  let!(:imp2) { create :publication_import,
                       publication: pub }

  let!(:grant1) { create :grant,
                         wos_agency_name: "Test Agency1",
                         wos_identifier: "GRANT-ID-123"}

  let!(:grant2) { create :grant,
                         wos_agency_name: "Test Agency2",
                         wos_identifier: "GRANT-ID-456"}

  let!(:rf1) { create :research_fund,
                      grant: grant1,
                      publication: pub }

  let!(:rf2) { create :research_fund,
                      grant: grant2,
                      publication: pub }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :publication, id: pub.id) }

      it "shows the publication detail heading" do
        expect(page).to have_content "Details for Publication 'Bob's Publication'"
      end

      it "shows the publication's type" do
        expect(page).to have_content "Academic Journal Article"
      end

      it "shows the publication's journal title" do
        expect(page).to have_content "Prestigious Journal"
      end

      it "shows the publication's publisher" do
        expect(page).to have_content "The Publisher"
      end

      it "shows the publication's status" do
        expect(page).to have_content "Published"
      end

      it "shows the publication's volume" do
        expect(page).to have_content "27"
      end

      it "shows the publication's issue" do
        expect(page).to have_content "39"
      end

      it "shows the publication's edition" do
        expect(page).to have_content "14"
      end

      it "shows the publication's page range" do
        expect(page).to have_content "12-15"
      end

      it "shows the publication's ISSN" do
        expect(page).to have_content "1234-5678"
      end

      it "shows the publication's DOI" do
        expect(page).to have_link "https://example.doi.org/test", href: "https://example.doi.org/test"
      end

      it "shows the publication's publication date" do
        expect(page).to have_content "August 01, 2018"
      end

      it "shows the publication's authorships" do
        expect(page).to have_link "Authorship ##{auth1.id}"
        expect(page).to have_link "Authorship ##{auth2.id}"
      end

      it "shows the publication's users" do
        expect(page).to have_link "Bob Testuser"
        expect(page).to have_link "Susan Tester"
      end

      it "shows the publication's contributors" do
        expect(page).to have_link "Jill Author"
        expect(page).to have_link "Jack Contributor"
      end

      it "shows the publication's grants" do
        expect(page).to have_link "GRANT-ID-123"
        expect(page).to have_link "GRANT-ID-456"
      end

      it "shows the publication's imports" do
        expect(page).to have_link "PublicationImport ##{imp1.id}"
        expect(page).to have_link "PublicationImport ##{imp2.id}"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :publication, id: pub.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :publication, id: pub.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
