require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin user detail page", type: :feature do
  let!(:user) { create(:user, first_name: 'Bob',
                       last_name: 'Testuser',
                       webaccess_id: 'bat123',
                       activity_insight_identifier: 'ai12345',
                       pure_uuid: 'pure67890',
                       penn_state_identifier: 'psu345678') }

  let!(:pub1) { create :publication, title: "Bob's First Publication",
                       journal_title: "First Journal",
                       publisher: "First Publisher",
                       published_on: Date.new(2017, 1, 1) }

  let!(:pub2) { create :publication, title: "Bob's Second Publication",
                       journal_title: "Second Journal",
                       publisher: "Second Publisher",
                       published_on: Date.new(2018, 1, 1),
                       duplicate_group: group }

  let(:group) { create :duplicate_publication_group }

  context "when the current user is an admin" do
    before do
      authenticate_admin_user
      create :authorship, user: user, publication: pub1
      create :authorship, user: user, publication: pub2
    end

    describe "the page content" do
      before { visit "admin/user/#{user.id}" }

      it "shows the user detail heading" do
        expect(page).to have_content "Details for User 'Bob Testuser'"
      end

      it "shows the user's WebAccess ID" do
        expect(page).to have_content 'bat123'
      end

      it "shows the user's Activity Insight ID" do
        expect(page).to have_content 'ai12345'
      end

      it "shows the user's Pure ID" do
        expect(page).to have_content 'pure67890'
      end

      it "shows the user's Penn State ID" do
        expect(page).to have_content 'psu345678'
      end

      it "shows the user's publications" do
        expect(page).to have_link "Bob's First Publication"
        expect(page).to have_content "First Journal"
        expect(page).to have_content "First Publisher"
        expect(page).to have_content "2017"

        expect(page).to have_link "Bob's Second Publication"
        expect(page).to have_content "Second Journal"
        expect(page).to have_content "Second Publisher"
        expect(page).to have_content "2018"
        expect(page).to have_link "Duplicate group ##{group.id}"
      end
    end

    describe "the page layout" do
      before { visit "admin/user/#{user.id}" }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit "admin/user/#{user.id}"
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
