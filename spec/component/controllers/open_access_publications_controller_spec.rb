require 'component/component_spec_helper'

describe OpenAccessPublicationsController, type: :controller do
  let!(:user) { create :user }
  let!(:other_user) { create :user }
  let!(:pub) { create :publication }
  let!(:blank_oa_pub) { create :publication, open_access_url: "", user_submitted_open_access_url: "" }
  let!(:oa_pub) { create :publication, open_access_url: "url" }
  let!(:uoa_pub) { create :publication, user_submitted_open_access_url: "url" }
  let!(:other_pub) { create :publication }
  let!(:uploaded_pub) { create :publication }
  let!(:other_uploaded_pub) { create :publication }
  let!(:auth) { create :authorship, user: user, publication: pub }
  let!(:waived_pub) { create :publication }
  let!(:other_waived_pub) { create :publication }
  let!(:auth) { create :authorship, user: user, publication: pub }
  let!(:waived_auth) { create :authorship, user: user, publication: waived_pub}
  let!(:other_waived_auth) { create :authorship, user: other_user, publication: other_waived_pub}
  let!(:uploaded_auth) { create :authorship, user: user, publication: uploaded_pub }
  let!(:other_uploaded_auth) { create :authorship, user: other_user, publication: other_uploaded_pub }

  before do
    create :authorship, user: user, publication: oa_pub
    create :authorship, user: user, publication: uoa_pub

    create :authorship,
           user: user,
           publication: other_uploaded_pub
    create :authorship, user: user, publication: blank_oa_pub
    create :authorship,
           user: user,
           publication: other_waived_pub

    create :scholarsphere_work_deposit, authorship: uploaded_auth, status: 'Pending'
    create :scholarsphere_work_deposit, authorship: other_uploaded_auth, status: 'Pending'

    create :internal_publication_waiver,
           authorship: waived_auth
    create :internal_publication_waiver,
           authorship: other_waived_auth
  end

  describe '#edit' do
    context "when not authenticated" do
      it "redirects to the home page" do
        get :edit, params: {id: 1}

        expect(response).to redirect_to root_path
      end

      it "sets a flash error message" do
        get :edit, params: {id: 1}

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end

    context "when authenticated" do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { get :edit, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "returns 200 OK" do
          get :edit, params: {id: oa_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: oa_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "returns 200 OK" do
          get :edit, params: {id: uoa_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: uoa_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "returns 200 OK" do
          get :edit, params: {id: uploaded_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: uploaded_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "returns 200 OK" do
          get :edit, params: {id: other_uploaded_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: other_uploaded_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication for which the user has waived open access" do
        it "returns 200 OK" do
          get :edit, params: {id: waived_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: waived_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication for which another user has waived open access" do
        it "returns 200 OK" do
          get :edit, params: {id: other_waived_pub.id}
          expect(response.code).to eq "200"
        end

        it "renders a readonly view of the publication" do
          expect(get :edit, params: {id: other_waived_pub.id}).to render_template(:readonly_edit)
        end
      end

      context "when given the ID for a publication that belongs to the user and is not open access" do
        context "when the open access fields are nil" do          
          it "returns 200 OK" do
            get :edit, params: {id: pub.id}
            expect(response.code).to eq "200"
          end

          it "renders the open access form" do
            expect(get :edit, params: {id: pub.id}).to render_template(:edit)
          end
        end
        context "when the open access fields are blank" do
          it "returns 200 OK" do
            get :edit, params: {id: blank_oa_pub.id}
            expect(response.code).to eq "200"
          end

          it "renders the open access form" do
            expect(get :edit, params: {id: pub.id}).to render_template(:edit)
          end
        end
      end
    end
  end

  describe '#update' do
    context "when not authenticated" do
      it "redirects to the home page" do
        patch :update, params: {id: 1}

        expect(response).to redirect_to root_path
      end

      it "sets a flash error message" do
        patch :update, params: {id: 1}

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end

    context "when authenticated" do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { patch :update, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: oa_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(oa_pub)
        end
        
        it "does not set a flash message" do
          patch :update, params: {id: oa_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: uoa_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uoa_pub)
        end

        it "does not set a flash message" do
          patch :update, params: {id: uoa_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uploaded_pub)
        end

        it "does not set a flash message" do
          patch :update, params: {id: uploaded_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: other_uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_uploaded_pub)
        end

        it "does not set a flash message" do
          patch :update, params: {id: other_uploaded_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication for which the user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(waived_pub)
        end

        it "does not set a flash message" do
          patch :update, params: {id: waived_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication for which another user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: other_waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_waived_pub)
        end

        it "does not set a flash message" do
          patch :update, params: {id: other_waived_pub.id}
          expect(flash[:notice]).to be_blank
          expect(flash[:alert]).to be_blank
        end
      end

      context "when given the ID for a publication that has an unknown open access status" do
        let(:form) { double 'open access URL form',
                            valid?: valid,
                            open_access_url: "a_url",
                            errors: errors }
        let(:valid) { true }
        let(:errors) { double 'errors', full_messages: error_messages }
        let(:error_messages) { [] }
        before do
          allow(OpenAccessURLForm).to receive(:new).with(ActionController::Parameters.new({open_access_url: "a_url"}).permit([:open_access_url])).and_return(form)
          patch :update, params: {id: pub.id, open_access_url_form: {open_access_url: "a_url"}}
        end

        context "when the given params are valid" do
          it "updates the given publication with the given URL" do
            expect(pub.reload.user_submitted_open_access_url).to eq "a_url"
          end
          it "sets a success message" do
            expect(flash[:notice]).to eq I18n.t('profile.open_access_publications.update.success')
          end
          it "redirects to the profile publications list" do
            expect(response).to redirect_to edit_profile_publications_path
          end
        end

        context "when the given params are invalid" do
          let(:valid) { false }
          let(:error_messages) { ["Invalid!"] }

          it "sets an error message" do
            expect(flash[:alert]).to eq "Validation failed:  Invalid!"
          end

          it "renders the edit page again" do
            expect(response).to render_template :edit
          end
        end
      end
    end
  end

  describe '#create_scholarsphere_deposit' do
    let(:found_deposit) { ScholarsphereWorkDeposit.find_by(authorship: auth) }
    before { allow(ScholarsphereUploadJob).to receive(:perform_later) }

    context "when not authenticated" do
      it "redirects to the sign in page" do
        post :create_scholarsphere_deposit, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      let(:now) { Time.new 2019, 1, 1, 0, 0, 0 }

      before do
        allow(Time).to receive(:current).and_return(now)
        authenticate_as(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { post :create_scholarsphere_deposit, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: oa_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(oa_pub)
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: uoa_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uoa_pub)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uploaded_pub)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: other_uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_uploaded_pub)
        end
      end

      context "when given the ID for a publication for which the user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(waived_pub)
        end
      end

      context "when given the ID for a publication for which another user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          post :create_scholarsphere_deposit, params: {id: other_waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_waived_pub)
        end
      end

      context "when given the ID for a publication that belongs to the user and is not open access" do
        let(:pub_id) { pub.id }
        let(:file) { fixture_file_upload('test_file.pdf', "application/pdf") }
        let(:params) {
          {
            id: pub_id,
            scholarsphere_work_deposit: {
              title: 'test',
              description: 'test',
              published_date: '2021-03-30',
              rights: 'https://creativecommons.org/licenses/by/4.0/',
              deposit_agreement: '1',
              file_uploads_attributes: [file: file]
            }
          }
        }

        context "when given valid params" do

          it "creates a new scholarsphere work deposit" do
            expect do 
              post :create_scholarsphere_deposit, params: params
            end.to change { ScholarsphereWorkDeposit.count }.by 1
            expect(found_deposit).not_to be_nil
          end

          it "saves the uploaded file to the new scholarsphere work deposit" do
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

          it "sets a success message" do
            post :create_scholarsphere_deposit, params: params
            expect(flash[:notice]).to eq I18n.t('profile.open_access_publications.create_scholarsphere_deposit.success')
          end

          it "schedules a job to send the publication to ScholarSphere" do
            post :create_scholarsphere_deposit, params: params
            expect(ScholarsphereUploadJob).to have_received(:perform_later).with(found_deposit.id, user.id)
          end
        end

        context "when given no file param for the scholarsphere work deposit" do
          let(:file) { nil }
          it "does not create a new scholarsphere work deposit" do
            expect do 
              post :create_scholarsphere_deposit, params: params
            end.not_to change { ScholarsphereWorkDeposit.count }
          end

          it "does not create any new file upload records" do
            expect do 
              post :create_scholarsphere_deposit, params: params
            end.not_to change { ScholarsphereFileUpload.count }
          end

          it "does not set the modification timestamp on the user's authorship of the publication" do
            post :create_scholarsphere_deposit, params: params
            expect(auth.reload.updated_by_owner_at).to be_nil
          end

          it "does not schedule a job to send the publication to ScholarSphere" do
            post :create_scholarsphere_deposit, params: params
            expect(ScholarsphereUploadJob).not_to have_received(:perform_later)
          end

          it "sets an error message" do
            post :create_scholarsphere_deposit, params: params
            expect(flash.now[:alert]).not_to be_empty
          end

          it "rerenders the form" do
            post :create_scholarsphere_deposit, params: params
            expect(response).to render_template :edit
          end
        end
      end
    end
  end
end
