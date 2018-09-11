require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin duplicate publication group detail page", type: :feature do
  let!(:pub1) { create :publication,
                       title: "Duplicate Publication",
                       secondary_title: "subtitle1",
                       journal_title: "journal1",
                       publisher: "publisher1",
                       published_on: Date.new(2018, 8, 13),
                       status: "status1",
                       volume: "volume1",
                       issue: "issue1",
                       edition: "edition1",
                       page_range: "pages1",
                       issn: "issn1",
                       publication_type: "Trade Journal Article",
                       duplicate_group: group }
  let!(:pub2) { create :publication,
                       title: "A duplicate publication",
                       secondary_title: "subtitle2",
                       journal_title: "journal2",
                       publisher: "publisher2",
                       published_on: Date.new(2018, 8, 14),
                       status: "status2",
                       volume: "volume2",
                       issue: "issue2",
                       edition: "edition2",
                       page_range: "pages2",
                       issn: "issn2",
                       publication_type: "Academic Journal Article",
                       duplicate_group: group }

  let(:group) { create :duplicate_publication_group }

  let(:user1) { create :user, first_name: "Test1", last_name: "User1" }
  let(:user2) { create :user, first_name: "Test2", last_name: "User2" }
  let(:user3) { create :user, first_name: "Test3", last_name: "User3" }

  let!(:con1) { create :contributor,
                       first_name: "Test1",
                       last_name: "Contributor1",
                       publication: pub1,
                       position: 2 }
  let!(:con2) { create :contributor,
                       first_name: "Test2",
                       last_name: "Contributor2",
                       publication: pub1,
                       position: 1 }
  let!(:con3) { create :contributor,
                       first_name: "Test3",
                       last_name: "Contributor3",
                       publication: pub2,
                       position: 1 }

  before do
    create :authorship, publication: pub1, user: user1
    create :authorship, publication: pub2, user: user2
    create :authorship, publication: pub2, user: user3

    create :publication_import, publication: pub1, source: "Pure", source_identifier: "pure-abc123"
    create :publication_import, publication: pub1, source: "Pure", source_identifier: "pure-xyz789"
    create :publication_import, publication: pub2, source: "Activity Insight", source_identifier: "ai-abc123"
    create :publication_import, publication: pub2, source: "Activity Insight", source_identifier: "ai-xyz789"
  end

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

      it "shows the ids of the publications in the group" do
        expect(page).to have_content pub1.id
        expect(page).to have_content pub2.id
      end

      it "shows the titles of the publications in the group" do
        expect(page).to have_link "Duplicate Publication"
        expect(page).to have_link "A duplicate publication"
      end

      it "shows the subtitles of the publications in the group" do
        expect(page).to have_content "subtitle1"
        expect(page).to have_content "subtitle2"
      end

      it "shows the journal names of the publications in the group" do
        expect(page).to have_content "journal1"
        expect(page).to have_content "journal2"
      end

      it "shows the publishers of the publications in the group" do
        expect(page).to have_content "publisher1"
        expect(page).to have_content "publisher2"
      end

      it "shows the publication dates of the publications in the group" do
        expect(page).to have_content "2018-08-13"
        expect(page).to have_content "2018-08-14"
      end

      it "shows the statuses of the publications in the group" do
        expect(page).to have_content "status1"
        expect(page).to have_content "status2"
      end

      it "shows the volumes of the publications in the group" do
        expect(page).to have_content "volume1"
        expect(page).to have_content "volume2"
      end

      it "shows the issues of the publications in the group" do
        expect(page).to have_content "issue1"
        expect(page).to have_content "issue2"
      end

      it "shows the editions of the publications in the group" do
        expect(page).to have_content "edition1"
        expect(page).to have_content "edition2"
      end

      it "shows the pages of the publications in the group" do
        expect(page).to have_content "pages1"
        expect(page).to have_content "pages2"
      end

      it "shows the ISSNs of the publications in the group" do
        expect(page).to have_content "issn1"
        expect(page).to have_content "issn2"
      end

      it "shows the types of the publications in the group" do
        expect(page).to have_content "Trade Journal Article"
        expect(page).to have_content "Academic Journal Article"
      end

      it "shows the user names for the publications in the group" do
        expect(page).to have_link "Test1 User1"
        expect(page).to have_link "Test2 User2"
        expect(page).to have_link "Test3 User3"
      end

      it "shows the contributor names for the publications in the group" do
        expect(page).to have_content "Test2 Contributor2, Test1 Contributor1"
        expect(page).to have_content "Test3 Contributor3"
      end

      it "shows the import identifiers for the publications in the group" do
        expect(page).to have_content "pure-abc123, pure-xyz789"
        expect(page).to have_content "ai-abc123, ai-xyz789"
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
