require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "Admin external publication waiver detail page", type: :feature do
  let!(:waiver) { create :external_publication_waiver,
                         user: user,
                         publication_title: "A Publication with a Distinct Title of Some Sort",
                         reason_for_waiver: "Just because.",
                         abstract: "What this publication is all about.",
                         doi: "https://doi.org/the-doi",
                         journal_title: "Test Journal",
                         publisher: "Test Publisher" }
  let!(:user) { create :user, first_name: "Joe", last_name: "Testerson" }

  context "when the current user is an admin" do
    before { authenticate_admin_user }

    describe "the page content" do
      before { visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id) }

      it "shows the waiver detail heading" do
        expect(page).to have_content "Details for External publication waiver 'A Publication with a Distinct Title of Some Sort'"
      end

      it "shows the title of the publication associated with the waiver" do
        expect(page).to have_content "A Publication with a Distinct Title of Some Sort"
      end

      it "shows the reason for the waiver" do
        expect(page).to have_content "Just because."
      end

      it "shows the publication's abstract" do
        expect(page).to have_content "What this publication is all about."
      end

      it "shows the publication's doi" do
        expect(page).to have_content "https://doi.org/the-doi"
      end

      it "shows the publication's journal title" do
        expect(page).to have_content "Test Journal"
      end

      it "shows the publication's publisher" do
        expect(page).to have_content "Test Publisher"
      end

      it "shows the name of the user associated with the waiver" do
        expect(page).to have_link "Joe Testerson", href: rails_admin.show_path(model_name: :user, id: user.id)
      end

      context "when there are publications in the database that match the title in the waiver" do
        let!(:user1) { create :user, first_name: 'Author', last_name: "One" }
        let!(:user2) { create :user, first_name: 'Author', last_name: "Two" }
        let!(:user3) { create :user, first_name: 'Author', last_name: "Three" }
        let!(:pub1) { create :publication,
                             title: "A test publication with a long, distinct title of some sort",
                             published_on: Date.new(2011, 1, 1),
                             journal_title: "Some Journal" }
        let!(:pub2) { create :publication,
                             title: "Another publication",
                             secondary_title: "with a longer, distinct title of some sort",
                             published_on: Date.new(1999, 1, 1),
                             journal_title: "Another Journal" }
        let!(:pub3) { create :publication,
                             title: "Some Other Publication" }

        let!(:auth1) { create :authorship, user: user, publication: pub1 }
        let!(:auth2) { create :authorship, user: user1, publication: pub1 }
        let!(:auth3) { create :authorship, user: user2, publication: pub1 }
        let!(:auth4) { create :authorship, user: user3, publication: pub2 }

        context "when the waiver has not already been linked to a publication" do
          before { visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id) }

          it "lists the matching publications" do
            within "#publication_#{pub1.id}" do
              expect(page).to have_link "A test publication with a long, distinct title of some sort"
              expect(page).to have_content "2011"
              expect(page).to have_content "Some Journal"
              expect(page).to have_content "Joe Testerson, Author One, Author Two"
            end

            within "#publication_#{pub2.id}" do
              expect(page).to have_link "Another publication"
              expect(page).to have_content "1999"
              expect(page).to have_content "Another Journal"
              expect(page).to have_content "Author Three"
            end

            expect(page).not_to have_content "Some Other Publication"
          end

          describe "linking a publication to the waiver" do
            before do
              within "#publication_#{pub1.id}" do
                click_on "Link Waiver"
              end
            end

            it "links the waiver to the user's authorship for the selected publication" do
              expect(InternalPublicationWaiver.find_by(authorship: auth1)).not_to be_nil
            end

            it "redirects to the waiver list" do
              expect(page.current_path).to eq rails_admin.index_path(model_name: :external_publication_waiver)
            end

            it "shows a success message" do
              expect(page).to have_content I18n.t('admin.publication_waiver_links.create.success')
            end
          end
        end

        context "when the waiver has already been linked to a publication" do
          let!(:int_waiver) { create :internal_publication_waiver, authorship: auth1 }
          before do
            waiver.update_attributes!(internal_publication_waiver: int_waiver)
            visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id)
          end

          it "does not list matching publications" do
            expect(page).not_to have_content "2011"
            expect(page).not_to have_content "Some Journal"
            expect(page).not_to have_content "Joe Testerson, Author One, Author Two"

            expect(page).not_to have_link "Another publication"
            expect(page).not_to have_content "1999"
            expect(page).not_to have_content "Another Journal"
            expect(page).not_to have_content "Author Three"

            expect(page).not_to have_content "Some Other Publication"
          end

          it "shows a link to the internal waiver" do
            expect(page).to have_link "A test publication with a long, distinct title of some sort"
          end
        end
      end
    end

    describe "the page layout" do
      before { visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id) }

      it_behaves_like "a page with the admin layout"
    end
  end

  context "when the current user is not an admin" do
    before { authenticate_user }
    it "redirects back to the home page with an error message" do
      visit rails_admin.show_path(model_name: :external_publication_waiver, id: waiver.id)
      expect(page.current_path).to eq root_path
      expect(page).to have_content I18n.t('admin.authorization.not_authorized')
    end
  end
end
