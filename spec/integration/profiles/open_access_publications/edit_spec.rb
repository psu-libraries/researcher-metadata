# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'visiting the page to edit the open access status of a publication', type: :feature do
  let(:user) { create(:user, webaccess_id: 'xyz123', first_name: 'Robert', last_name: 'Author') }
  let(:pub) { create(:publication,
                     title: 'Test Publication',
                     secondary_title: 'The Subtitle',
                     issue: '583',
                     volume: '971',
                     page_range: '478-483',
                     published_on: Date.new(2019, 3, 17),
                     doi: 'https://doi.org/10.1109/5.771073',
                     abstract: 'An abstract of the test publication',
                     journal: journal) }
  let!(:auth) { create(:authorship, user: user, publication: pub) }
  let!(:journal) { create(:journal,
                          title: 'A Prestegious Journal') }
  let!(:name) { create(:contributor_name,
                       publication: pub,
                       user: user,
                       position: 1,
                       first_name: 'Bob',
                       last_name: 'Author') }
  let(:other_pub) { create(:publication) }
  let(:non_article_pub) { create(:publication,
                                 publication_type: 'Book') }
  let(:oa_pub) { create(:publication,
                        title: 'Open Access Publication',
                        journal_title: 'Open Access Journal',
                        issue: '834',
                        volume: '620',
                        page_range: '112-124',
                        published_on: Date.new(2020, 1, 1),
                        open_access_locations: [build(:open_access_location,
                                                      source: Source::OPEN_ACCESS_BUTTON,
                                                      url: 'a_url')]) }
  let(:ss_pub) { create(:publication,
                        title: 'Scholarsphere Publication',
                        journal_title: 'Another Journal',
                        issue: '54',
                        volume: '16',
                        page_range: '63-81',
                        published_on: Date.new(2018, 1, 1)) }
  let(:waived_pub) { create(:publication,
                            title: 'Waived Publication',
                            journal_title: 'Closed Access Journal',
                            issue: '89',
                            volume: '27',
                            page_range: '160-173',
                            published_on: Date.new(2017, 1, 1)) }
  let(:response) { double 'response' }

  let!(:waived_auth) { create(:authorship, user: user, publication: waived_pub) }
  let!(:ss_deposited_auth) { create(:authorship, user: user, publication: ss_pub) }
  let!(:swd) { create(:scholarsphere_work_deposit, authorship: ss_deposited_auth, status: 'Pending') }

  before do
    create(:authorship, user: user, publication: oa_pub)

    create(:authorship, user: user, publication: non_article_pub)
    create(:internal_publication_waiver, authorship: waived_auth)

    allow(HTTParty).to receive(:head).and_return(response)
    allow(response).to receive(:code).and_return 200
  end

  context 'when the user is not signed in' do
    before { visit edit_open_access_publication_path(pub) }

    it 'does not allow them to visit the page' do
      expect(page).to have_no_current_path edit_open_access_publication_path(pub), ignore_query: true
    end
  end

  context 'when the user is signed in' do
    before { authenticate_as(user) }

    context 'when requesting a publication that belongs to the user' do
      before do
          sleep 0.5
          visit edit_open_access_publication_path(pub)
      end

      it_behaves_like 'a profile management page'

      it 'shows the title of the publication' do
        expect(page).to have_content 'Test Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'A Prestegious Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '583'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '971'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '478-483'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2019'
      end

      it 'shows a link to the open access waiver' do
        expect(page).to have_link 'Waive open access obligations for this publication', href: new_internal_publication_waiver_path(pub)
      end

      describe 'successfully submitting the form to add an open access URL' do
        before do
          fill_in 'Open Access URL', with: 'https://example.org/pubs/1.pdf'
          click_on 'Submit URL'
        end

        it 'updates the publication with the submitted URL' do
          expect(pub.reload.user_submitted_open_access_url).to eq 'https://example.org/pubs/1.pdf'
        end

        it 'redirects back to the publication list' do
          expect(page).to have_current_path edit_profile_publications_path, ignore_query: true
        end

        it 'shows a success message' do
          expect(page).to have_content I18n.t('profile.open_access_publications.update.success')
        end
      end

      describe 'submitting the form to add an open access URL with an error' do
        before do
          fill_in 'Open Access URL', with: 'derp derp derp'
          click_on 'Submit URL'
        end

        it 'does not update the publication with the submitted data' do
          expect(pub.reload.user_submitted_open_access_url).to be_nil
        end

        it 'rerenders the form' do
          expect(page).to have_current_path open_access_publication_path(pub), ignore_query: true
          expect(page).to have_field 'Open Access URL'
        end

        it 'shows an error message' do
          expect(page).to have_content I18n.t('models.open_access_url_form.validation_errors.url_format')
        end
      end

      describe 'file upload and version check', :js do
        include ActiveJob::TestHelper
        let(:file_store) { ActiveSupport::Cache.lookup_store(:file_store, file_caching_path) }
        let(:cache) { Rails.cache }
        let(:file_handler) { instance_double(ScholarsphereFileHandler,
                                             version: exif_version,
                                             cache_files: [cache_file], valid?: true) }

        before do
          allow(ScholarsphereFileHandler).to receive(:new).and_return(file_handler)
          allow(Rails).to receive(:cache).and_return(file_store)
          Rails.cache.clear

          perform_enqueued_jobs do
            attach_file('File', test_file)
            click_on 'Submit Files'
          end
        end

        context 'when exif check returns unknown' do
          let(:exif_version) { 'unknown' }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_unknown_version.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" } }

          it 'does not preselect anything' do
            expect(page).to have_content('We were not able to determine the version of your uploaded publication article', wait: 10)
            expect(find_field('scholarsphere_work_deposit_file_version_acceptedversion').checked?).to be false
            expect(find_field('scholarsphere_work_deposit_file_version_publishedversion').checked?).to be false
          end
        end

        context 'when exif check returns a acceptedVersion' do
          let(:exif_version) { I18n.t('file_versions.accepted_version') }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_accepted_version_postprint.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_accepted_version_postprint.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_accepted_version_postprint.pdf" } }

          it 'preselects Accepted Manuscript' do
            expect(page).to have_content('This looks like the Accepted Manuscript of the article.')
            expect(find_field('scholarsphere_work_deposit_file_version_acceptedversion').checked?).to be true
          end
        end

        context 'when exif check returns nil and pdf check returns acceptedVersion' do
          let(:exif_version) { nil }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_accepted_version_postprint.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_accepted_version_postprint.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_accepted_version_postprint.pdf" } }

          it 'preselects Accepted Manuscript' do
            expect(page).to have_content('This looks like the Accepted Manuscript of the article.', wait: 10)
            expect(find_field('scholarsphere_work_deposit_file_version_acceptedversion').checked?).to be true
          end
        end

        context 'when exif check returns publishedVersion' do
          let(:exif_version) { I18n.t('file_versions.published_version') }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_published_versionS123456abc.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf" } }

          it 'preselects Final Published Version' do
            expect(page).to have_content('This looks like the Final Published Version of the article.')
            expect(find_field('scholarsphere_work_deposit_file_version_publishedversion').checked?).to be true
          end
        end

        context 'when exif check returns nil and pdf check returns publishedVersion' do
          let(:exif_version) { nil }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_published_versionS123456abc.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf" } }

          it 'preselects Final Published Version' do
            expect(page).to have_content('This looks like the Final Published Version of the article.', wait: 10)
            expect(find_field('scholarsphere_work_deposit_file_version_publishedversion').checked?).to be true
          end
        end

        context 'when nothing is found' do
          let(:exif_version) { nil }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_unknown_version.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" } }

          it 'does not preselect anything' do
            expect(page).to have_content('We were not able to determine the version of your uploaded publication article', wait: 10)
            expect(find_field('scholarsphere_work_deposit_file_version_acceptedversion').checked?).to be false
            expect(find_field('scholarsphere_work_deposit_file_version_publishedversion').checked?).to be false
          end
        end

        # Tagged as glacial.  This test takes over a minute to complete.
        context 'when timeout is reached', :glacial do
          let(:exif_version) { nil }
          let(:test_file) { "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" }
          let(:cache_file) { { original_filename: 'pdf_check_unknown_version.pdf',
                               cache_path: "#{Rails.root}/spec/fixtures/pdf_check_unknown_version.pdf" } }

          it 'displays spinner for 60 seconds; then, displays selection and does not preselect anything' do
            allow_any_instance_of(OpenAccessPublicationsController).to receive(:file_version_result).and_return(nil)
            sleep 10
            expect(page).to have_content('Attempting to determine file version, please wait...')
            sleep 10
            expect(page).to have_content('Attempting to determine file version, please wait...')
            sleep 10
            expect(page).to have_content('Attempting to determine file version, please wait...')
            sleep 10
            expect(page).to have_content('Attempting to determine file version, please wait...')
            sleep 10
            expect(page).to have_content('Attempting to determine file version, please wait...')
            expect(page).to have_no_content('Attempting to determine file version, please wait...', wait: 15)
            expect(page).to have_content('We were not able to determine the version of your uploaded publication article.', wait: 15)
            expect(find_field('scholarsphere_work_deposit_file_version_acceptedversion').checked?).to be false
            expect(find_field('scholarsphere_work_deposit_file_version_publishedversion').checked?).to be false
          end
        end
      end

      describe 'completing the workflow', :js do
        include ActiveJob::TestHelper
        let(:file_store) { ActiveSupport::Cache.lookup_store(:file_store, file_caching_path) }
        let(:cache) { Rails.cache }

        before do
          allow(Rails).to receive(:cache).and_return(file_store)
          Rails.cache.clear

          perform_enqueued_jobs do
            click_on 'Add Another File'
            sleep 0.5
            file_elements = find_all('input[type="file"]')
            file_elements.each do |file|
              file.attach_file("#{Rails.root}/spec/fixtures/test_file.pdf")
            end
            click_on 'Submit Files'
            find_field('scholarsphere_work_deposit_file_version_acceptedversion', wait: 10)
            sleep 0.25
            choose 'scholarsphere_work_deposit_file_version_acceptedversion'
            click_on 'Submit'
          end
        end

        describe 'viewing the form to deposit a publication in ScholarSphere' do
          it 'shows metadata from the publication and pre-fills the form fields with the correct values' do
            within '#new_scholarsphere_work_deposit' do
              expect(page).to have_link('test_file.pdf').twice
              expect(find_field('Title').value).to eq 'Test Publication'
              expect(find_field('Subtitle').value).to eq 'The Subtitle'
              expect(page).to have_content 'Creators'
              expect(page).to have_content 'Bob Author'
              expect(find_field('Description').value).to eq 'An abstract of the test publication'
              expect(page).to have_field 'Publisher Statement'
              expect(find_field('scholarsphere_work_deposit_published_date_1i').value).to eq '2019'
              expect(find_field('scholarsphere_work_deposit_published_date_2i').value).to eq '3'
              expect(find_field('scholarsphere_work_deposit_published_date_3i').value).to eq '17'
              expect(find_field('Journal Name').value).to eq 'A Prestegious Journal'
              expect(find_field('DOI').value).to eq 'https://doi.org/10.1109/5.771073'
            end
          end
        end

        describe 'changing some pre-filled values and successfully submitting the form to deposit a publication in ScholarSphere' do
          include ActiveJob::TestHelper
          let(:ingest) { double 'scholarsphere client ingest', publish: response }
          let(:response) { double 'scholarsphere client response', status: status, body: response_body }
          let(:response_body) { %{{"url": "/the-url"}} }
          let(:status) { 200 }

          before do
            allow(Scholarsphere::Client::Ingest).to receive(:new).and_return ingest
            allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return 'https://scholarsphere.test'
            within '#new_scholarsphere_work_deposit' do
              perform_enqueued_jobs do
                fill_in 'Subtitle', with: 'New Subtitle'
                fill_in 'Publisher Statement', with: 'A set statement from the publisher'
                select 'Public Domain Mark 1.0', from: 'License'
                check 'I have read and agree to the deposit agreement.'
                select Date.today.year + 1, from: 'scholarsphere_work_deposit_embargoed_until_1i'
                select 'May', from: 'scholarsphere_work_deposit_embargoed_until_2i'
                select '22', from: 'scholarsphere_work_deposit_embargoed_until_3i'
                click_button 'Submit Files'
                sleep 0.5
              end
            end
          end

          it 'creates a ScholarSphere work deposit record with the correct metadata' do
            dep = ScholarsphereWorkDeposit.find_by(title: 'Test Publication')
            expect(dep.authorship).to eq auth
            expect(dep.subtitle).to eq 'New Subtitle'
            expect(dep.status).to eq 'Success'
            expect(dep.error_message).to be_nil
            expect(dep.title).to eq 'Test Publication'
            expect(dep.description).to eq 'An abstract of the test publication'
            expect(dep.publisher_statement).to eq 'A set statement from the publisher'
            expect(dep.published_date).to eq Date.new(2019, 3, 17)
            expect(dep.rights).to eq 'http://creativecommons.org/publicdomain/mark/1.0/'
            expect(dep.embargoed_until).to eq Date.new((Date.today.year + 1), 5, 22)
            expect(dep.doi).to eq 'https://doi.org/10.1109/5.771073'
            expect(dep.publisher).to eq 'A Prestegious Journal'
            expect(dep.deposit_workflow).to eq 'Standard OA Workflow'
          end

          it 'sends a request to deposit the publication in ScholarSphere' do
            ScholarsphereWorkDeposit.find_by(title: 'Test Publication')
            expect(Scholarsphere::Client::Ingest).to have_received(:new) do |args|
              expect(args).to be_a Hash
              expect(args.keys).to contain_exactly(:metadata, :files, :depositor)
              expect(args[:metadata]).to eq({
                                              creators: [{ display_name: 'Bob Author', psu_id: 'xyz123' }],
                                              description: 'An abstract of the test publication',
                                              publisher_statement: 'A set statement from the publisher',
                                              identifier: ['https://doi.org/10.1109/5.771073'],
                                              published_date: Date.new(2019, 3, 17),
                                              publisher: ['A Prestegious Journal'],
                                              rights: 'http://creativecommons.org/publicdomain/mark/1.0/',
                                              subtitle: 'New Subtitle',
                                              title: 'Test Publication',
                                              visibility: 'open',
                                              work_type: 'article',
                                              embargoed_until: Date.new((Date.today.year + 1), 5, 22)
                                            })
              expect(args[:depositor]).to eq 'xyz123'
              expect(args[:files]).to be_an Array
              expect(args[:files].length).to eq 2
              expect(args[:files].first).to be_a File
            end
            expect(ingest).to have_received(:publish)
          end

          it 'updates the publication with the URL returned from ScholarSphere' do
            expect(pub.reload.scholarsphere_open_access_url).to eq 'https://scholarsphere.test/the-url'
          end

          it 'notifies the user by email that the deposit was successful' do
            open_email('xyz123@psu.edu')
            expect(current_email.body).to match(/Test A Person/)
            expect(current_email.body).to match(/Test Publication/)
            expect(current_email.body).to match(/https:\/\/scholarsphere\.test\/the-url/)
          end

          it 'returns the user to their profile publication list' do
            expect(page).to have_current_path edit_profile_publications_path, ignore_query: true
          end

          it 'shows a success message' do
            expect(page).to have_content 'Thank you'
          end

          it 'shows the publication with the correct status' do
            within "#authorship_row_#{auth.id}" do
              expect(page).to have_css '.fa-unlock-alt'
              expect(page).to have_content pub.title
              expect(page).to have_no_link pub.title
            end
          end
        end
      end

      describe 'submitting a valid form with an error in the deposit process' do
        include ActiveJob::TestHelper
        let(:ingest) { double 'scholarsphere client ingest' }
        let(:file_handler) { instance_double(ScholarsphereFileHandler,
                                             version: I18n.t('file_versions.published_version'),
                                             cache_files: [cache_file],
                                             valid?: true) }
        let(:cache_file) { { original_filename: 'pdf_check_published_versionS123456abc.pdf',
                             cache_path: "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf" }.with_indifferent_access }

        before do
          allow(Scholarsphere::Client::Ingest).to receive(:new).and_return ingest
          allow(ingest).to receive(:publish).and_raise RuntimeError.new('Oh no! Failure!')
          allow(ScholarsphereFileHandler).to receive(:new).and_return(file_handler)

          perform_enqueued_jobs do
            suppress(RuntimeError) do
              attach_file('File', "#{Rails.root}/spec/fixtures/pdf_check_published_versionS123456abc.pdf")
              click_on 'Submit Files'
              find_field('scholarsphere_work_deposit_file_version_acceptedversion', wait: 10)
              choose 'scholarsphere_work_deposit_file_version_acceptedversion'
              click_on 'Submit'

              fill_in 'Subtitle', with: 'New Subtitle'
              select 'Public Domain Mark 1.0', from: 'License'
              check 'I have read and agree to the deposit agreement.'
              select Date.today.year + 1, from: 'scholarsphere_work_deposit_embargoed_until_1i'
              select 'May', from: 'scholarsphere_work_deposit_embargoed_until_2i'
              select '22', from: 'scholarsphere_work_deposit_embargoed_until_3i'
              click_button 'Submit Files'
            end
          end
        end

        it 'creates a ScholarSphere work deposit record with the correct metadata' do
          dep = ScholarsphereWorkDeposit.find_by(title: 'Test Publication')
          expect(dep.authorship).to eq auth
          expect(dep.subtitle).to eq 'New Subtitle'
          expect(dep.status).to eq 'Failed'
          expect(dep.error_message).to eq 'Oh no! Failure!'
          expect(dep.title).to eq 'Test Publication'
          expect(dep.description).to eq 'An abstract of the test publication'
          expect(dep.published_date).to eq Date.new(2019, 3, 17)
          expect(dep.rights).to eq 'http://creativecommons.org/publicdomain/mark/1.0/'
          expect(dep.embargoed_until).to eq Date.new((Date.today.year + 1), 5, 22)
          expect(dep.doi).to eq 'https://doi.org/10.1109/5.771073'
          expect(dep.publisher).to eq 'A Prestegious Journal'
          expect(dep.deposit_workflow).to eq 'Standard OA Workflow'
        end

        it 'shows the publication with the correct status in the profile publication list' do
          visit edit_profile_publications_path
          within "#authorship_row_#{auth.id}" do
            expect(page).to have_css '.fa-exclamation-circle'
            expect(page).to have_link pub.title
          end
        end

        it 'notifies the user by email that the deposit failed' do
          open_email('xyz123@psu.edu')
          expect(current_email.body).to match(/Test A Person/)
          expect(current_email.body).to match(/Test Publication/)
          expect(current_email.body).to match(/issue uploading/)
        end

        it "does not update the publication's ScholarSphere open access URL" do
          expect(pub.reload.scholarsphere_open_access_url).to be_nil
        end
      end
    end

    context 'when requesting a publication that belongs to the user and has an open access URL' do
      before { visit edit_open_access_publication_path(oa_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Open Access Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Open Access Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '834'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '620'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '112-124'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2020'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'This publication is open access'
        expect(page).to have_link 'a_url', href: 'a_url'
      end
    end

    context 'when requesting a publication that belongs to the user and has a pending Scholarsphere upload' do
      before { visit edit_open_access_publication_path(ss_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Scholarsphere Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Another Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '54'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '16'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '63-81'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2018'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'This publication is in the process of being added to Scholarsphere'
      end
    end

    context 'when requesting a publication that belongs to the user and has had open access waived' do
      before { visit edit_open_access_publication_path(waived_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Waived Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Closed Access Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '89'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '27'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '160-173'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2017'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'Open access obligations have been waived for this publication'
      end
    end

    context 'when requesting a publication that does not belong to the user' do
      it 'returns 404' do
        visit edit_open_access_publication_path(other_pub)
        expect(page.status_code).to eq 404
      end
    end

    context 'when requesting a publication that is not a journal article' do
      it 'returns 404' do
        visit edit_open_access_publication_path(non_article_pub)
        expect(page.status_code).to eq 404
      end
    end
  end
end
