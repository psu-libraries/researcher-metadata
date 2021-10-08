require 'integration/integration_spec_helper'
require 'support/webdrivers'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin list of publications by organization", type: :feature do
  context "when the current user is an admin", js: true do
    before { authenticate_admin_user }

    let(:user1) { create :user }
    let(:user2) { create :user }

    let(:pub1) { create :publication, title: 'Pub One', published_on: Date.new(2000, 1, 1) }
    let(:pub2) { create :publication, title: 'Pub Two', published_on: Date.new(2000, 1, 1) }
    let(:pub3) { create :publication, title: 'Pub Three' }
    let(:pub4) { create :publication, title: 'Pub Four', published_on: Date.new(2020, 1, 1) }
    let(:pub5) { create :publication, title: 'Pub Five', published_on: Date.new(1980, 1, 1)}

    let(:org) { create :organization }
    let(:child_org) { create :organization, parent: org }
    let(:other_org) { create :organization }

    let!(:mem1) { create :user_organization_membership,
                         user: user1,
                         organization: org,
                         started_on: Date.new(1990, 1, 1),
                         ended_on: Date.new(2010, 1, 1) }
    let!(:mem2) { create :user_organization_membership,
                         user: user2,
                         organization: child_org,
                         started_on: Date.new(1990, 1, 1) }
    let!(:mem3) { create :user_organization_membership,
                         user: user1,
                         organization: other_org,
                         started_on: Date.new(1970, 1, 1) }

    let!(:auth1) { create :authorship, user: user1, publication: pub1 }
    let!(:auth2) { create :authorship, user: user2, publication: pub2 }
    let!(:auth3) { create :authorship, user: user1, publication: pub4 }
    let!(:auth4) { create :authorship, user: user1, publication: pub5 }

    describe "navigating to the publication list from an organization" do
      before do
        visit rails_admin.show_path(model_name: :organization, id: org.id)
        click_on "View Publications"
      end

      it "loads the list of publications" do
        expect(page.current_path).to eq RailsAdmin.railtie_routes_url_helpers.index_publications_by_organization_path(model_name: :publication)
        expect(page).to have_content "List of Publications by Organization"
      end
    end

    describe "the page content" do
      before { visit_index }

      it "shows the publication list heading" do
        expect(page).to have_content 'List of Publications by Organization'
      end

      it "shows information about only the publication for the given organization" do
        expect(page).to have_content pub1.id
        expect(page).to have_content 'Pub One'

        expect(page).to have_content pub2.id
        expect(page).to have_content 'Pub Two'

        expect(page).to have_content '2 publications'

        expect(page).not_to have_content 'Pub Three'
        expect(page).not_to have_content 'Pub Four'
        expect(page).not_to have_content 'Pub Five'
      end
    end

    describe "filtering the list" do
      before do
        visit_index
        fill_in 'query', with: 'Two'
        click_on 'Refresh'
      end

      it "shows information about only the publication for the given organization that match the filter criteria" do
        expect(page).to have_content pub2.id
        expect(page).to have_content 'Pub Two'

        expect(page).to have_content '1 publication'

        expect(page).not_to have_content 'Pub One'
        expect(page).not_to have_content 'Pub Three'
        expect(page).not_to have_content 'Pub Four'
        expect(page).not_to have_content 'Pub Five'
      end
    end

    describe "pagination of the list" do
      before do
        (3..26).each do |i|
          pub = create :publication, title: "Pub #{i}", published_on: Date.new(2000, 1, 1)
          create :authorship, user: user1, publication: pub
          visit_index
        end
      end

      it "correctly paginates the results with 25 items per page" do
        expect(page).to have_content "26 publications"
        expect(page).to have_content "Pub Two"
        (3..26).each do |i|
          expect(page).to have_content "Pub #{i}"
        end
        expect(page).not_to have_content "Pub One"

        click_link "2"

        expect(page).to have_content "26 publications"
        expect(page).not_to have_content "Pub Two"
        (3..26).each do |i|
          expect(page).not_to have_content "Pub #{i}"
        end
        expect(page).to have_content "Pub One"
      end
    end

    describe "exporting found publications" do
      before do
        visit_index
        click_on "Export found Publications"
      end

      it "shows the correct page for selecting export options" do
        expect(page.current_path).to eq RailsAdmin.railtie_routes_url_helpers.export_publications_by_organization_path(model_name: :publication)
        expect(page).to have_content "Export Publications by Organization"
      end

      describe "selecting the CSV export" do
        before do
          clear_downloads

          visit_index
          click_on "Export found Publications"
          
          check('all', allow_label_click: true)
          check('schema_only_id', allow_label_click: true)
          check('schema_only_title', allow_label_click: true)
          click_on "Export to csv"
          wait_for_downloads
        end

        it "produces a CSV file" do
          expect(download_directory.children.count).to eq(1)
        end
      end
    end

    describe "exporting to Activity Insight" do
      before do
        visit_index
        click_on "Export to Activity Insight"
      end

      it "shows the correct page/info for exporting to Activity Insight" do
        expect(page.current_path).to eq RailsAdmin.railtie_routes_url_helpers.export_publications_to_activity_insight_path(model_name: :publication)
        expect(page).to have_content "You have found 2 publications from test organization"
        expect(page).to have_button "Integrate with Beta"
        expect(page).to have_button "Integrate with Production"
      end
    end

    describe "the page layout" do
      before { visit_index }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.index_publications_by_organization_path(model_name: :publication)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end

def visit_index
  visit RailsAdmin.railtie_routes_url_helpers.index_publications_by_organization_path(model_name: :publication, org_id: org.id)
end
