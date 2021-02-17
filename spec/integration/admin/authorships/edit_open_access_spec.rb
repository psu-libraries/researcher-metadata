require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "setting an open access URL", type: :feature do
  let!(:user1) { create(:user,
                        first_name: 'Susan',
                        last_name: 'Tester') }
  let!(:user2) { create(:user,
                        first_name: 'Bob',
                        last_name: 'Testuser') }

  let!(:pub) { create :publication, title: "A Test Publication" }

  let!(:auth1) { create :authorship,
                        publication: pub,
                        user: user1,
                        author_number: 5,
                        scholarsphere_uploaded_at: Time.new(2020, 1, 22, 16, 8, 0, 0) }
  let!(:auth2) { create :authorship,
                        publication: pub,
                        user: user2,
                        author_number: 5,
                        scholarsphere_uploaded_at: Time.new(2019, 12, 15, 10, 9, 0, 0) }
  let!(:other_auth) { create :authorship, scholarsphere_uploaded_at: nil }

  describe "visiting the page to update a publication open access URL via an authorship" do
    context "when the current user is an admin" do
      before { authenticate_admin_user }

      context "when the authorship has a ScholarSphere upload timestamp" do
        describe "the page content" do
          before { visit rails_admin.edit_open_access_path(model_name: :authorship, id: auth1.id) }

          it "shows the correct page heading" do
            expect(page).to have_content "Open Access Settings"
          end
        end

        describe "the page layout" do
          before { visit rails_admin.edit_open_access_path(model_name: :authorship, id: auth1.id) }

          it_behaves_like "a page with the admin layout"
        end

        describe "submitting an invalid URL" do
          before do
            visit rails_admin.edit_open_access_path(model_name: :authorship, id: auth1.id)
            fill_in "Scholarsphere Open Access URL", with: 'invalid'
            click_button "Save"
          end

          it "renders the form again" do
            expect(page).to have_field "Scholarsphere Open Access URL"
          end

          it "shows an error message" do
            expect(page).to have_content I18n.t('models.open_access_url_form.validation_errors.url_format')
          end

          it "does not update the authorship's publication" do
            expect(pub.reload.scholarsphere_open_access_url).to be_nil
          end

          it "does not update the ScholarSphere upload timestamps on the related publication's authorships" do
            expect(auth1.reload.scholarsphere_uploaded_at).to eq Time.new(2020, 1, 22, 16, 8, 0, 0)
            expect(auth2.reload.scholarsphere_uploaded_at).to eq Time.new(2019, 12, 15, 10, 9, 0, 0)
          end
        end

        describe "submitting a valid URL" do
          before do
            visit rails_admin.edit_open_access_path(model_name: :authorship, id: auth1.id)
            fill_in "Scholarsphere Open Access URL", with: 'https://google.com'
            click_button "Save"
          end

          it "redirects to the authorship list" do
            expect(page.current_path).to eq rails_admin.index_path(model_name: :authorship)
          end

          it "shows a success message" do
            expect(page).to have_content I18n.t('admin.actions.edit_open_access.success', pub.title)
          end

          it "updates the authorship's publication" do
            expect(pub.reload.scholarsphere_open_access_url).to eq 'https://google.com'
          end

          it "deletes the ScholarSphere upload timestamps on the related publication's authorships" do
            expect(auth1.reload.scholarsphere_uploaded_at).to be_nil
            expect(auth2.reload.scholarsphere_uploaded_at).to be_nil
          end
        end
      end
      context "when the authorship does not have a ScholarSphere upload timestamp" do
        before { visit rails_admin.edit_open_access_path(model_name: :authorship, id: other_auth.id) }
        it "redirects to the authorship list" do
          expect(page.current_path).to eq rails_admin.index_path(model_name: :authorship)
        end
        it "shows an error message" do
          expect(page).to have_content I18n.t('admin.actions.edit_open_access.error')
        end
      end
      context "taking the action for an object that is not an authorship" do
        it "raises an error" do
          expect { visit rails_admin.edit_open_access_path(model_name: :publication, id: pub.id) }
            .to raise_error RailsAdmin::ActionNotAllowed
        end
      end
    end

    context "when the current user is not an admin" do
      before { authenticate_user }
      it "redirects back to the home page with an error message" do
        visit rails_admin.edit_open_access_path(model_name: :authorship, id: auth1.id)
        expect(page.current_path).to eq root_path
        expect(page).to have_content I18n.t('admin.authorization.not_authorized')
      end
    end
  end
end
