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
                      publisher_name: "The Publisher",
                      published_on: Date.new(2017, 1, 1),
                      publication_type: "Academic Journal Article",
                      status: "Published",
                      volume: "27",
                      issue: "39",
                      edition: "14",
                      page_range: "12-15",
                      issn: "1234-5678",
                      doi: "https://doi.org/10.000/test",
                      open_access_url: "https://openaccess.org/publications/1",
                      user_submitted_open_access_url: "https://example.org/publications/2",
                      journal: journal,
                      scholarsphere_open_access_url: "https://scholarsphere.psu.edu/resources/3",
                      published_on: Date.new(2018, 8, 1),
                      open_access_button_last_checked_at: Time.new(2021, 7, 15, 13, 15, 0, "-00:00") }

  let!(:auth1) { create :authorship,
                        publication: pub,
                        user: user1 }

  let!(:auth2) { create :authorship,
                        publication: pub,
                        user: user2 }

  let!(:con1) { create :contributor_name,
                       publication: pub,
                       first_name: "Jill",
                       last_name: "Author" }

  let!(:con2) { create :contributor_name,
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

  let!(:oal1) { create :open_access_location,
                       publication: pub }

  let!(:oal2) { create :open_access_location,
                       publication: pub }

  let!(:journal) { create :journal,
                          title: "Test Journal Record" }

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
        expect(page).to have_link "https://doi.org/10.000/test", href: "https://doi.org/10.000/test"
      end

      it "shows a link to the publication's open access content" do
        expect(page).to have_link "https://openaccess.org/publications/1", href: "https://openaccess.org/publications/1"
      end

      it "shows a link to the publication's user-submitted open access content" do
        expect(page).to have_link "https://example.org/publications/2", href: "https://example.org/publications/2"
      end

      it "shows a link to the publication's open access content in Scholarsphere" do
        expect(page).to have_link "https://scholarsphere.psu.edu/resources/3", href: "https://scholarsphere.psu.edu/resources/3"
      end
      
      it "shows the publication's publication date" do
        expect(page).to have_content "August 01, 2018"
      end

      it "shows the publication's authorships" do
        expect(page).to have_link "##{auth1.id} (Bob Testuser - Bob's Publication)"
        expect(page).to have_link "##{auth2.id} (Susan Tester - Bob's Publication)"
      end

      it "shows the publication's users" do
        expect(page).to have_link "Bob Testuser"
        expect(page).to have_link "Susan Tester"
      end

      it "shows the names of the publication's contributors" do
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

      it "shows the publication's open access locations" do
        expect(page).to have_link "OpenAccessLocation ##{oal1.id}",
                                  href: rails_admin.show_path(model_name: :open_access_location, id: oal1.id)
        expect(page).to have_link "OpenAccessLocation ##{oal2.id}",
                                  href: rails_admin.show_path(model_name: :open_access_location, id: oal2.id)
      end

      it "shows the publication's journal" do
        expect(page).to have_link "Test Journal Record", href: rails_admin.show_path(model_name: :journal, id: journal.id)
      end

      it "shows when Open Access Button was last checked for the publication" do
        expect(page).to have_content "July 15, 2021 13:15"
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
