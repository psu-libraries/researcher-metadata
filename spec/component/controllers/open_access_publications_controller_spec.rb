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

  before do
    create :authorship, user: user, publication: oa_pub
    create :authorship, user: user, publication: uoa_pub
    create :authorship,
           user: user,
           publication: uploaded_pub,
           scholarsphere_uploaded_at: Time.new(2019, 12, 6, 0, 0, 0)
    create :authorship,
           user: user,
           publication: other_uploaded_pub
    create :authorship,
           user: other_user,
           publication: other_uploaded_pub,
           scholarsphere_uploaded_at: Time.new(2019, 12, 6, 0, 0, 0)
    create :authorship, user: user, publication: blank_oa_pub


    create :authorship,
           user: user,
           publication: other_waived_pub

    create :internal_publication_waiver,
           authorship: waived_auth
    create :internal_publication_waiver,
           authorship: other_waived_auth
  end

  describe '#edit' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        get :edit, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      before do
        authenticate_as(user)
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
      it "redirects to the sign in page" do
        patch :update, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      before do
        authenticate_as(user)
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
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: uoa_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uoa_pub)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(uploaded_pub)
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: other_uploaded_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_uploaded_pub)
        end
      end

      context "when given the ID for a publication for which the user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(waived_pub)
        end
      end

      context "when given the ID for a publication for which another user has waived open access" do
        it "redirects to the read-only view of the publication's open access status" do
          patch :update, params: {id: other_waived_pub.id}
          expect(response).to redirect_to edit_open_access_publication_path(other_waived_pub)
        end
      end
    end
  end

  describe '#create_scholarsphere_deposit' do
    let(:service) { double 'scholarsphere deposit service', create: nil }
    let(:found_deposit) { ScholarsphereWorkDeposit.find_by(authorship: auth) }

    before do
      allow(ScholarsphereDepositService).to receive(:new).and_return(service)
    end

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

        it "creates a new scholarsphere work deposit" do
          expect do 
            post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: file]}}
          end.to change { ScholarsphereWorkDeposit.count }.by 1
          expect(found_deposit).not_to be_nil
        end

        it "saves the uploaded file to the new scholarsphere work deposit" do
          post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: file]}}

          expect(found_deposit.file_uploads.count).to eq 1
          expect(found_deposit.file_uploads.first.file.identifier).to eq file.original_filename
        end

        it "sets the modification timestamp on the user's authorship of the publication" do
          post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: file]}}
          expect(auth.reload.updated_by_owner_at).to eq now
        end
          
        it "redirects to the publication management page for the user's profile" do
          post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: file]}}
          expect(response).to redirect_to edit_profile_publications_path
        end

        context "when the work deposit record has been successfully created" do
          let(:created_deposit) { double 'scholarsphere work deposit', reload: reloaded_deposit }
          let(:reloaded_deposit) { double 'scholarsphere work deposit' }
          before do
            allow(ScholarsphereDepositService).to receive(:new).with(reloaded_deposit, user).and_return(service)
            allow(ScholarsphereWorkDeposit).to receive(:create!).with(authorship: auth).and_return(created_deposit)
            allow(created_deposit).to receive(:update!)
          end

          it "sends a message to the service" do
            expect(service).to receive(:create)
            post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: file]}}
          end
        end

        context "when given no scholarsphere work deposit param" do
          it "sets an error message" do
            post :create_scholarsphere_deposit, params: {id: pub_id}
            expect(flash.now[:alert]).to eq I18n.t('profile.open_access_publications.create_scholarsphere_deposit.missing_parameter_error')
          end

          it "rerenders the form" do
            post :create_scholarsphere_deposit, params: {id: pub_id}
            expect(response).to render_template :edit
          end
        end

        context "when given no file param for the scholarsphere work deposit" do
          it "does not create a new scholarsphere work deposit" do
            expect do 
              post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: nil]}}
            end.not_to change { ScholarsphereWorkDeposit.count }
          end

          it "does not create any new file upload records" do
            expect do 
              post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: nil]}}
            end.not_to change { ScholarsphereFileUpload.count }
          end

          it "does not set the modification timestamp on the user's authorship of the publication" do
            post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: nil]}}
            expect(auth.reload.updated_by_owner_at).to be_nil
          end

          it "sets an error message" do
            post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: nil]}}
            expect(flash.now[:alert]).not_to be_empty
          end

          it "rerenders the form" do
            post :create_scholarsphere_deposit, params: {id: pub_id, scholarsphere_work_deposit: {file_uploads_attributes: [file: nil]}}
            expect(response).to render_template :edit
          end
        end
      end
    end
  end
end
