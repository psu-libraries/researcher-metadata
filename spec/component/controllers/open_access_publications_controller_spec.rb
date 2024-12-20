# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe OpenAccessPublicationsController, type: :controller do
  let!(:assignment) { create(:deputy_assignment) }
  let!(:user) { UserDecorator.new(user: assignment.primary, impersonator: deputy) }
  let!(:deputy) { nil }
  let!(:other_user) { create(:user) }
  let!(:pub) { create(:publication) }
  let!(:blank_oa_pub) { create(:publication, open_access_locations: []) }
  let!(:oa_pub) { create(:publication, open_access_locations: [build(:open_access_location, :open_access_button)]) }
  let!(:uoa_pub) { create(:publication, open_access_locations: [build(:open_access_location, :user)]) }
  let!(:other_pub) { create(:publication) }
  let!(:uploaded_pub) { create(:publication) }
  let!(:other_uploaded_pub) { create(:publication) }
  let!(:unpublished_pub) { create(:publication, status: 'In Press') }
  let!(:auth) { create(:authorship, user: user, publication: pub) }
  let!(:waived_pub) { create(:publication) }
  let!(:other_waived_pub) { create(:publication) }
  let!(:waived_auth) { create(:authorship, user: user, publication: waived_pub) }
  let!(:other_waived_auth) { create(:authorship, user: other_user, publication: other_waived_pub) }
  let!(:uploaded_auth) { create(:authorship, user: user, publication: uploaded_pub) }
  let!(:other_uploaded_auth) { create(:authorship, user: other_user, publication: other_uploaded_pub) }
  let!(:unconfirmed_pub) { create(:publication) }

  before do
    create(:authorship, user: user, publication: oa_pub)
    create(:authorship, user: user, publication: uoa_pub)

    create(:authorship,
           user: user,
           publication: other_uploaded_pub)
    create(:authorship, user: user, publication: blank_oa_pub)
    create(:authorship,
           user: user,
           publication: other_waived_pub)
    create(:authorship,
           user: user,
           publication: unconfirmed_pub,
           confirmed: false)

    create(:scholarsphere_work_deposit, authorship: uploaded_auth, status: 'Pending')
    create(:scholarsphere_work_deposit, authorship: other_uploaded_auth, status: 'Pending')

    create(:internal_publication_waiver,
           authorship: waived_auth)
    create(:internal_publication_waiver,
           authorship: other_waived_auth)
  end

  describe '#edit' do
    let(:perform_request) { get :edit, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for a publication that does not belong to the user' do
        it 'returns 404' do
          expect { get :edit, params: { id: other_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that is not published' do
        it 'returns 404' do
          expect { get :edit, params: { id: unpublished_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user but is unconfirmed' do
        it 'returns 404' do
          expect { get :edit, params: { id: unconfirmed_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user and has an open access URL' do
        it 'returns 200 OK' do
          get :edit, params: { id: oa_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: oa_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication that belongs to the user and has a user-submitted open access URL' do
        it 'returns 200 OK' do
          get :edit, params: { id: uoa_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: uoa_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by the user' do
        it 'returns 200 OK' do
          get :edit, params: { id: uploaded_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: uploaded_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by another user' do
        it 'returns 200 OK' do
          get :edit, params: { id: other_uploaded_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: other_uploaded_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication for which the user has waived open access' do
        it 'returns 200 OK' do
          get :edit, params: { id: waived_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: waived_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication for which another user has waived open access' do
        it 'returns 200 OK' do
          get :edit, params: { id: other_waived_pub.id }
          expect(response).to have_http_status :ok
        end

        it 'renders a readonly view of the publication' do
          expect(get(:edit, params: { id: other_waived_pub.id })).to render_template(:readonly_edit)
        end
      end

      context 'when given the ID for a publication that belongs to the user and is not open access' do
        context 'when the open access fields are nil' do
          it 'returns 200 OK' do
            get :edit, params: { id: pub.id }
            expect(response).to have_http_status :ok
          end

          it 'renders the open access form' do
            expect(get(:edit, params: { id: pub.id })).to render_template(:edit)
          end
        end

        context 'when the open access fields are blank' do
          it 'returns 200 OK' do
            get :edit, params: { id: blank_oa_pub.id }
            expect(response).to have_http_status :ok
          end

          it 'renders the open access form' do
            expect(get(:edit, params: { id: pub.id })).to render_template(:edit)
          end
        end
      end
    end
  end

  describe '#update' do
    let(:perform_request) { patch :update, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for a publication that does not belong to the user' do
        it 'returns 404' do
          expect { patch :update, params: { id: other_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that is not published' do
        it 'returns 404' do
          expect { patch :update, params: { id: unpublished_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user but is unconfirmed' do
        it 'returns 404' do
          expect { get :update, params: { id: unconfirmed_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user and has an open access URL' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: oa_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(oa_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: oa_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication that belongs to the user and has a user-submitted open access URL' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: uoa_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(uoa_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: uoa_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by the user' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: uploaded_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(uploaded_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: uploaded_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by another user' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: other_uploaded_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(other_uploaded_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: other_uploaded_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication for which the user has waived open access' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: waived_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(waived_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: waived_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication for which another user has waived open access' do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: { id: other_waived_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(other_waived_pub)
        end

        it 'does not set a flash message' do
          patch :update, params: { id: other_waived_pub.id }
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context 'when given the ID for a publication that has an unknown open access status' do
        let(:form) { double 'open access URL form',
                            valid?: valid,
                            open_access_url: 'a_url',
                            errors: errors }
        let(:valid) { true }
        let(:errors) { double 'errors', full_messages: error_messages }
        let(:error_messages) { [] }

        before do
          allow(OpenAccessURLForm).to receive(:new).with(ActionController::Parameters.new({ open_access_url: 'a_url' }).permit([:open_access_url])).and_return(form)
          patch :update, params: { id: pub.id, open_access_url_form: { open_access_url: 'a_url' } }
        end

        context 'when the given params are valid' do
          it 'updates the given publication with the given URL' do
            expect(pub.reload.user_submitted_open_access_url).to eq 'a_url'
          end

          it 'sets a success message' do
            expect(flash[:notice]).to eq I18n.t('profile.open_access_publications.update.success')
          end

          it 'redirects to the profile publications list' do
            expect(response).to redirect_to edit_profile_publications_path
          end
        end

        context 'when the given params are invalid' do
          let(:valid) { false }
          let(:error_messages) { ['Invalid!'] }

          it 'sets an error message' do
            expect(flash[:alert]).to eq 'Validation failed:  Invalid!'
          end

          it 'renders the edit page again' do
            expect(response).to render_template :edit
          end
        end

        context 'when the user is a deputy impersonating another user' do
          let(:deputy) { assignment.deputy }

          it 'sets the deputy user id of the url' do
            expect(pub.reload.open_access_locations.map(&:deputy_user_id)).to contain_exactly(deputy.id)
          end
        end
      end
    end
  end

  describe '#scholarsphere_file_version' do
    let(:perform_request) { post :scholarsphere_file_version, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when is not open access' do
        let(:file) { fixture_file_upload('test_file.pdf', 'application/pdf') }
        let(:params) {
          {
            id: pub.id,
            scholarsphere_work_deposit: {
              file_uploads_attributes: { '0' => { file: file } }
            }
          }
        }

        context 'when given valid params' do
          context 'when given file does not return a version from exif check' do
            let(:file_handler) { double 'ScholarsphereFileHandler', valid?: true, cache_files: [cache_file], version: nil }
            let(:pdf_file_version_job) { double 'ScholarsphereVersionCheckJob', provider_job_id: 10, job_id: 1 }
            let(:cache_file) { { original_filename: 'test_file.pdf', cache_path: "#{Rails.root}/spec/fixtures/test_file.pdf" } }
            let(:file_path) { cache_file[:cache_path] }

            before do
              allow(ScholarsphereFileHandler).to receive(:new).and_return(file_handler)
              allow(ScholarsphereVersionCheckJob).to receive(:perform_later).and_return(pdf_file_version_job)
            end

            it 'begins file version check and renders the scholarsphere_file_version form' do
              post :scholarsphere_file_version, params: params
              expect(response).to render_template :scholarsphere_file_version
              expect(ScholarsphereVersionCheckJob).to have_received(:perform_later).with(file_path: file_path, publication_id: pub.id)
            end
          end

          context 'when given file returns a version from exif check' do
            let(:file_handler) { double 'ScholarsphereFileHandler', valid?: true, cache_files: [cache_file], version: I18n.t('file_versions.published_version') }
            let(:cache_file) { { original_filename: 'test_file.pdf', cache_path: "#{Rails.root}/spec/fixtures/test_file.pdf" } }

            before do
              allow(ScholarsphereFileHandler).to receive(:new).and_return(file_handler)
              allow(ScholarsphereVersionCheckJob).to receive(:perform_later)
            end

            it 'does not begin file version check and renders the scholarsphere_file_version form' do
              post :scholarsphere_file_version, params: params
              expect(response).to render_template :scholarsphere_file_version
              expect(ScholarsphereVersionCheckJob).not_to have_received(:perform_later)
            end
          end

          context 'when given file returns unknown from exif version checker' do
            let(:file_handler) { double 'ScholarsphereFileHandler', valid?: true, cache_files: [cache_file], version: 'unknown' }
            let(:cache_file) { { original_filename: 'test_file.pdf', cache_path: "#{Rails.root}/spec/fixtures/test_file.pdf" } }

            before do
              allow(ScholarsphereFileHandler).to receive(:new).and_return(file_handler)
              allow(ScholarsphereVersionCheckJob).to receive(:perform_later)
            end

            it 'does not begin file version check and renders the scholarsphere_file_version form' do
              post :scholarsphere_file_version, params: params
              expect(response).to render_template :scholarsphere_file_version
              expect(ScholarsphereVersionCheckJob).not_to have_received(:perform_later)
            end
          end
        end

        context 'when given no scholarsphere_work_deposit param' do
          let(:params) { { id: pub.id } }

          it 'sets an error message' do
            post :scholarsphere_file_version, params: params
            expect(flash.now[:alert]).not_to be_empty
          end

          it 'redirects to the edit form' do
            post :scholarsphere_file_version, params: params
            expect(response).to redirect_to(edit_open_access_publication_url)
          end
        end

        context 'when given no file param for the scholarsphere work deposit' do
          let(:file) { nil }

          it 'sets an error message' do
            post :scholarsphere_file_version, params: params
            expect(flash.now[:alert]).not_to be_empty
          end

          it 'redirects to the edit form' do
            post :scholarsphere_file_version, params: params
            expect(response).to redirect_to(edit_open_access_publication_url)
          end
        end
      end
    end
  end

  describe '#file_version_result' do
    let(:perform_request) { get :file_version_result, params: { id: pub.id, jobs: [job_id1, job_id2, job_id3] } }
    let(:job_id1) { { provider_id: 1, job_id: 'job_id_1' } }
    let(:job_id2) { { provider_id: 2, job_id: 'job_id_2' } }
    let(:job_id3) { { provider_id: 3, job_id: 'job_id_3' } }
    let(:file_path1) { '/path/to/file1.pdf' }
    let(:file_path2) { '/path/to/file2.pdf' }
    let(:file_path3) { '/path/to/file3.pdf' }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when pdf file version polling resolves with a version' do
        before do
          allow(Rails.cache).to receive(:read)
            .with("file_version_job_#{job_id1[:job_id]}")
            .and_return({ pdf_file_version: 'acceptedVersion', pdf_file_score: score1, file_path: file_path1 })
          allow(Rails.cache).to receive(:read)
            .with("file_version_job_#{job_id2[:job_id]}")
            .and_return({ pdf_file_version: 'publishedVersion', pdf_file_score: score2, file_path: file_path2 })
          allow(Rails.cache).to receive(:read)
            .with("file_version_job_#{job_id3[:job_id]}")
            .and_return({ pdf_file_version: 'unknown', pdf_file_score: 0, file_path: file_path3 })
        end

        context 'when the absolute score of the acceptedVersion is greater than the publishedVersion' do
          let(:score1) { -3 }
          let(:score2) { 1 }

          it 'renders the file version result partial with acceptedVersion as file_version and cache_files locals' do
            allow(controller).to receive(:render).and_call_original

            perform_request
            expect(controller).to have_received(:render).with(partial: 'open_access_publications/file_version_result',
                                                              locals: { file_version: 'acceptedVersion',
                                                                        cache_files: ['/path/to/file1.pdf', '/path/to/file2.pdf', '/path/to/file3.pdf'] })
          end
        end

        context 'when the absolute score of the publishedVersion is greater than the acceptedVersion' do
          let(:score1) { -1 }
          let(:score2) { 3 }

          it 'renders the file version result partial with publishedVersion as file_version and cache_files locals' do
            allow(controller).to receive(:render).and_call_original

            perform_request
            expect(controller).to have_received(:render).with(partial: 'open_access_publications/file_version_result',
                                                              locals: { file_version: 'publishedVersion',
                                                                        cache_files: ['/path/to/file1.pdf', '/path/to/file2.pdf', '/path/to/file3.pdf'] })
          end
        end

        context 'when the absolute score of the publishedVersion is equal to the acceptedVersion' do
          let(:score1) { -3 }
          let(:score2) { 3 }

          it 'renders the file version result partial with whatever is first in the list of file_versions and cache_files locals' do
            allow(controller).to receive(:render).and_call_original

            perform_request
            expect(controller).to have_received(:render).with(partial: 'open_access_publications/file_version_result',
                                                              locals: { file_version: 'acceptedVersion',
                                                                        cache_files: ['/path/to/file1.pdf', '/path/to/file2.pdf', '/path/to/file3.pdf'] })
          end
        end

        context 'when a job fails' do
          let(:score1) { -3 }
          let(:score2) { 1 }
          let!(:job) { Delayed::Job.create id: 1,
                                           handler: "--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper\njob_data:\n  " +
                                             "job_class: ScholarsphereVersionCheckJob\n  job_id: #{job_id1[:job_id]}\n  provider_job_id:\n  queue_nam" +
                                             "e: scholarsphere-pdf-file-version\n  priority:\n  arguments:\n  - file_path: /path/to/file1.pdf\n" +
                                             "    publication_id: 123456\n    _aj_ruby2_keywords:\n    - file_path\n    - publication_id\n  ex" +
                                             "ecutions: 0\n  exception_executions: {}\n  locale: en\n  timezone: UTC\n  enqueued_at: '2023-09-" +
                                             "08T18:19:35Z'\n",
                                           failed_at: DateTime.now }

          before do
            allow(controller).to receive(:render).and_call_original
            get :file_version_result, params: { id: pub.id, jobs: [job_id1, job_id2] }
          end

          it 'proceeds with analysis of the other job' do
            expect(controller).to have_received(:render).with(partial: 'open_access_publications/file_version_result',
                                                              locals: { file_version: 'publishedVersion',
                                                                        cache_files: ['/path/to/file1.pdf', '/path/to/file2.pdf'] })
          end
        end
      end

      context 'when there are no job ids' do
        before do
          get :file_version_result, params: { id: pub.id, jobs: [] }
        end

        it 'renders no_content' do
          perform_request

          expect(response.message).to eq 'No Content'
        end
      end

      context 'when the job has yet to complete' do
        let!(:job) { Delayed::Job.create id: 1,
                                         handler: "--- !ruby/object:ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper\njob_data:\n  " +
                                           "job_class: ScholarsphereVersionCheckJob\n  job_id: #{job_id1[:job_id]}\n  provider_job_id:\n  queue_nam" +
                                           "e: scholarsphere-pdf-file-version\n  priority:\n  arguments:\n  - file_path: /path/to/file1.pdf\n" +
                                           "    publication_id: 123456\n    _aj_ruby2_keywords:\n    - file_path\n    - publication_id\n  ex" +
                                           "ecutions: 0\n  exception_executions: {}\n  locale: en\n  timezone: UTC\n  enqueued_at: '2023-09-" +
                                           "08T18:19:35Z'\n" }

        before do
          get :file_version_result, params: { id: pub.id, jobs: [] }
        end

        it 'renders no_content' do
          perform_request

          expect(response.message).to eq 'No Content'
        end
      end
    end
  end

  describe '#scholarsphere_deposit_form' do
    let(:perform_request) { post :scholarsphere_deposit_form, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when is not open access' do
        let(:pub_id) { pub.id }
        let(:file) { fixture_file_upload('test_file.pdf', 'application/pdf') }
        let(:params) {
          {
            id: pub_id,
            scholarsphere_work_deposit: {
              cache_files: { '0' => { cache_path: file.path, original_filename: file.original_filename } }
            }
          }
        }

        context 'when given valid params' do
          it 'render the scholarsphere deposit form' do
            post :scholarsphere_deposit_form, params: params
            expect(response).to render_template :scholarsphere_deposit_form
          end
        end

        context 'when given no cache file param for the scholarsphere work deposit' do
          let(:params) { { id: pub_id } }

          it 'sets an error message' do
            post :scholarsphere_deposit_form, params: params
            expect(flash.now[:alert]).not_to be_empty
          end

          it 'rerenders the edit form' do
            post :scholarsphere_deposit_form, params: params
            expect(response).to render_template :edit
          end
        end
      end
    end
  end

  describe '#file_serve' do
    let(:perform_request) { post :scholarsphere_deposit_form, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when is not open access' do
        let(:pub_id) { pub.id }
        let(:file) { fixture_file_upload('test_file.pdf', 'application/pdf') }
        let(:file_version_params) { { file_uploads_attributes: { '0' => { file: file } } } }
        let(:file_handler) { ScholarsphereFileHandler.new(pub, file_version_params) }
        let(:cache_files)  { file_handler.cache_files }
        let(:cache_path) { cache_files.first[:cache_path] }
        let(:params) { { id: pub_id, filename: cache_path.to_s } }

        it 'renders the requested file' do
          post :file_serve, params: params
          expect(response.header['Content-Type']).to eq('application/pdf')
          expect(response.header['Content-Disposition']).to eq('inline; filename="test_file.pdf"; filename*=UTF-8\'\'test_file.pdf')
        end
      end
    end
  end

  describe '#create_scholarsphere_deposit' do
    let(:found_deposit) { ScholarsphereWorkDeposit.find_by(authorship: auth) }
    let(:perform_request) { post :create_scholarsphere_deposit, params: { id: 1 } }

    before { allow(ScholarsphereUploadJob).to receive(:perform_later) }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:now) { Time.new 2019, 1, 1, 0, 0, 0 }

      before do
        allow(Time).to receive(:current).and_return(now)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for a publication that does not belong to the user' do
        it 'returns 404' do
          expect { post :create_scholarsphere_deposit, params: { id: other_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that is not published' do
        it 'returns 404' do
          expect { post :create_scholarsphere_deposit, params: { id: unpublished_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user but is unconfirmed' do
        it 'returns 404' do
          expect { get :create_scholarsphere_deposit, params: { id: unconfirmed_pub.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a publication that belongs to the user and has an open access URL' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: oa_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(oa_pub)
        end
      end

      context 'when given the ID for a publication that belongs to the user and has a user-submitted open access URL' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: uoa_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(uoa_pub)
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by the user' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: uploaded_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(uploaded_pub)
        end
      end

      context 'when given the ID for a publication that has already been uploaded to ScholarSphere by another user' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: other_uploaded_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(other_uploaded_pub)
        end
      end

      context 'when given the ID for a publication for which the user has waived open access' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: waived_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(waived_pub)
        end
      end

      context 'when given the ID for a publication for which another user has waived open access' do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: { id: other_waived_pub.id }
          expect(response).to redirect_to edit_open_access_publication_path(other_waived_pub)
        end
      end

      context 'when given the ID for a publication that belongs to the user and is not open access' do
        let(:pub_id) { pub.id }
        let(:file) { fixture_file_upload('test_file.pdf', 'application/pdf') }
        let(:params) {
          {
            id: pub_id,
            scholarsphere_work_deposit: {
              title: 'test',
              description: 'test',
              published_date: '2021-03-30',
              rights: 'https://creativecommons.org/licenses/by/4.0/',
              deposit_agreement: '1',
              file_uploads_attributes: { '0' => { cache_path: cache_path } }
            }
          }
        }
        let(:file_version_params) {
          {
            file_uploads_attributes: { '0' => { file: file } }
          }
        }
        let(:file_handler) { ScholarsphereFileHandler.new(pub, file_version_params) }
        let(:cache_files) { file_handler.cache_files }
        let(:cache_path) do
          return nil if cache_files.empty?

          cache_files.first[:cache_path]
        end

        context 'when given valid params' do
          it 'creates a new scholarsphere work deposit' do
            expect do
              post :create_scholarsphere_deposit, params: params
            end.to change(ScholarsphereWorkDeposit, :count).by 1
            expect(found_deposit).not_to be_nil
          end

          it 'saves the uploaded file to the new scholarsphere work deposit' do
            post :create_scholarsphere_deposit, params: params

            expect(found_deposit.file_uploads.count).to eq 1
            expect(found_deposit.status).to eq 'Pending'
            expect(found_deposit.file_uploads.first.file.identifier).to eq file.original_filename
          end

          it "sets the modification timestamp on the user's authorship of the publication" do
            post :create_scholarsphere_deposit, params: params
            expect(auth.reload.updated_by_owner_at).to eq now
          end

          it "redirects to the publication management page for the user's profile" do
            post :create_scholarsphere_deposit, params: params
            expect(response).to redirect_to edit_profile_publications_path
          end

          it 'sets a success message' do
            post :create_scholarsphere_deposit, params: params
            expect(flash[:notice]).to eq I18n.t('profile.open_access_publications.create_scholarsphere_deposit.success')
          end

          it 'schedules a job to send the publication to ScholarSphere' do
            post :create_scholarsphere_deposit, params: params
            expect(ScholarsphereUploadJob).to have_received(:perform_later).with(found_deposit.id, user.id)
          end
        end

        context 'when the user is a deputy impersonating the primary user' do
          let(:deputy) { assignment.deputy }

          before { post :create_scholarsphere_deposit, params: params }

          it 'adds the deputy user id to the work deposit' do
            expect(found_deposit.deputy_user_id).to eq(deputy.id)
          end
        end

        context 'when given no cache_path for the scholarsphere work deposit' do
          let(:cache_path) { '' }

          it 'does not create a new scholarsphere work deposit' do
            expect do
              post :create_scholarsphere_deposit, params: params
            end.not_to change(ScholarsphereWorkDeposit, :count)
          end

          it 'does not create any new file upload records' do
            expect do
              post :create_scholarsphere_deposit, params: params
            end.not_to change(ScholarsphereFileUpload, :count)
          end

          it "does not set the modification timestamp on the user's authorship of the publication" do
            post :create_scholarsphere_deposit, params: params
            expect(auth.reload.updated_by_owner_at).to be_nil
          end

          it 'does not schedule a job to send the publication to ScholarSphere' do
            post :create_scholarsphere_deposit, params: params
            expect(ScholarsphereUploadJob).not_to have_received(:perform_later)
          end

          it 'sets an error message' do
            post :create_scholarsphere_deposit, params: params
            expect(flash.now[:alert]).not_to be_empty
          end

          it 'rerenders the form' do
            post :create_scholarsphere_deposit, params: params
            expect(response).to render_template :edit
          end
        end
      end
    end
  end
end
