require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "visiting the page to edit the open acess status of a publication" do
  let(:user) { create :user }
  let(:pub) { create :publication,
                     title: 'Test Publication',
                     journal_title: 'A Prestegious Journal',
                     issue: "583",
                     volume: "971",
                     page_range: "478-483",
                     published_on: Date.new(2019, 1, 1) }
  let(:other_pub) { create :publication }
  let(:oa_pub) { create :publication,
                        title: 'Open Access Publication',
                        journal_title: 'Open Access Journal',
                        issue: "834",
                        volume: "620",
                        page_range: "112-124",
                        published_on: Date.new(2020, 1, 1),
                        open_access_url: 'a_url' }
  let(:ss_pub) { create :publication,
                        title: 'Scholarsphere Publication',
                        journal_title: 'Another Journal',
                        issue: "54",
                        volume: "16",
                        page_range: "63-81",
                        published_on: Date.new(2018, 1, 1) }
  let(:waived_pub) { create :publication,
                            title: 'Waived Publication',
                            journal_title: 'Closed Access Journal',
                            issue: "89",
                            volume: "27",
                            page_range: "160-173",
                            published_on: Date.new(2017, 1, 1) }
  let(:response) { double 'response' }

  let!(:waived_auth) { create :authorship, user: user, publication: waived_pub }

  before do
    create :authorship, user: user, publication: pub
    create :authorship, user: user, publication: oa_pub
    create :authorship, user: user, publication: ss_pub, scholarsphere_uploaded_at: 1.day.ago
    create :internal_publication_waiver, authorship: waived_auth
    
    allow(HTTParty).to receive(:head).and_return(response)
    allow(response).to receive(:code).and_return 200
  end

  context "when the user is not signed in" do
    before { visit edit_open_access_publication_path(pub) }

    it "does not allow them to visit the page" do
      expect(page.current_path).not_to eq edit_open_access_publication_path(pub)
    end
  end

  context "when the user is signed in" do
    before { authenticate_as(user) }

    context "when requesting a publication that belongs to the user" do
      before { visit edit_open_access_publication_path(pub) }
      it_behaves_like "a profile management page"
      
      it "shows the title of the publication" do
        expect(page).to have_content "Test Publication"
      end
      it "shows the publication's journal" do
        expect(page).to have_content "A Prestegious Journal"
      end
      it "shows the publication's issue number" do
        expect(page).to have_content "583"
      end
      it "shows the publication's volume number" do
        expect(page).to have_content "971"
      end
      it "shows the publication's page range" do
        expect(page).to have_content "478-483"
      end
      it "shows the publication's year" do
        expect(page).to have_content "2019"
      end

      it "shows an upload button" do
        expect(page).to have_button "Upload"
      end

      it "shows a link to the open access waiver" do
        expect(page).to have_link "Waive open access obligations for this publication", href: new_internal_publication_waiver_path(pub)
      end

      describe "successfully submitting the form to add an open access URL" do
        before do
          fill_in "Open Access URL", with: 'https://example.org/pubs/1.pdf'
          click_on "Submit"
        end

        it "updates the publication with the sumbitted URL" do
          expect(pub.reload.user_submitted_open_access_url).to eq 'https://example.org/pubs/1.pdf'
        end

        it "redirects back to the publication list" do
          expect(page.current_path).to eq edit_profile_publications_path
        end

        it "shows a success message" do
          expect(page).to have_content I18n.t('profile.open_access_publications.update.success')
        end
      end

      describe "submitting the form to add an open access URL with an error" do
        before do
          fill_in "Open Access URL", with: 'derp derp derp'
          click_on "Submit"
        end

        it "does not update the publication with the sumbitted data" do
          expect(pub.reload.user_submitted_open_access_url).to be_nil
        end

        it "rerenders the form" do
          expect(page.current_path).to eq open_access_publication_path(pub)
          expect(page).to have_field "Open Access URL"
        end

        it "shows an error message" do
          expect(page).to have_content I18n.t('models.open_access_url_form.validation_errors.url_format')
        end
      end
    end

    context "when requesting a publication that belongs to the user and has an open access URL" do
      before { visit edit_open_access_publication_path(oa_pub) }

      it_behaves_like "a profile management page"
      
      it "shows an appropriate message" do
        expect(page).to have_content "no further action"
      end
      it "shows the title of the publication" do
        expect(page).to have_content "Open Access Publication"
      end
      it "shows the publication's journal" do
        expect(page).to have_content "Open Access Journal"
      end
      it "shows the publication's issue number" do
        expect(page).to have_content "834"
      end
      it "shows the publication's volume number" do
        expect(page).to have_content "620"
      end
      it "shows the publication's page range" do
        expect(page).to have_content "112-124"
      end
      it "shows the publication's year" do
        expect(page).to have_content "2020"
      end
      it "shows the open access status of the publication" do
        expect(page).to have_content "This publication is open access"
        expect(page).to have_link 'a_url', href: 'a_url'
      end
    end

    context "when requesting a publication that belongs to the user and has a pending Scholarsphere upload" do
      before { visit edit_open_access_publication_path(ss_pub) }

      it_behaves_like "a profile management page"
      
      it "shows an appropriate message" do
        expect(page).to have_content "no further action"
      end
      it "shows the title of the publication" do
        expect(page).to have_content "Scholarsphere Publication"
      end
      it "shows the publication's journal" do
        expect(page).to have_content "Another Journal"
      end
      it "shows the publication's issue number" do
        expect(page).to have_content "54"
      end
      it "shows the publication's volume number" do
        expect(page).to have_content "16"
      end
      it "shows the publication's page range" do
        expect(page).to have_content "63-81"
      end
      it "shows the publication's year" do
        expect(page).to have_content "2018"
      end
      it "shows the open access status of the publication" do
        expect(page).to have_content "This publication is in the process of being added to Scholarsphere"
      end
    end

    context "when requesting a publication that belongs to the user and has had open access waived" do
      before { visit edit_open_access_publication_path(waived_pub) }

      it_behaves_like "a profile management page"
      
      it "shows an appropriate message" do
        expect(page).to have_content "no further action"
      end
      it "shows the title of the publication" do
        expect(page).to have_content "Waived Publication"
      end
      it "shows the publication's journal" do
        expect(page).to have_content "Closed Access Journal"
      end
      it "shows the publication's issue number" do
        expect(page).to have_content "89"
      end
      it "shows the publication's volume number" do
        expect(page).to have_content "27"
      end
      it "shows the publication's page range" do
        expect(page).to have_content "160-173"
      end
      it "shows the publication's year" do
        expect(page).to have_content "2017"
      end
      it "shows the open access status of the publication" do
        expect(page).to have_content "Open access obligations have been waived for this publication"
      end
    end

    context "when requesting a publication that does not belong to the user" do
      it "returns 404" do
        expect { visit edit_open_access_publication_path(other_pub) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
