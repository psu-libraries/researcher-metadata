require 'component/component_spec_helper'

describe ScholarsphereUploadsController, type: :controller do

  describe '#create' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        post :create, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      let!(:user) { create :user }
      let!(:other_user) { create :user }
      let!(:pub) { create :publication }
      let!(:oa_pub) { create :publication, open_access_url: "url" }
      let!(:uoa_pub) { create :publication, user_submitted_open_access_url: "url" }
      let!(:other_pub) { create :publication }
      let!(:uploaded_pub) { create :publication }
      let!(:other_uploaded_pub) { create :publication }
      let!(:waived_pub) { create :publication }
      let!(:other_waived_pub) { create :publication }
      let!(:auth) { create :authorship, user: user, publication: pub }
      let!(:waived_auth) { create :authorship, user: user, publication: waived_pub}
      let!(:other_waived_auth) { create :authorship, user: other_user, publication: other_waived_pub}

      let(:now) { Time.new 2019, 1, 1, 0, 0, 0 }

      before do
        allow(Time).to receive(:current).and_return(now)
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

        create :authorship,
               user: user,
               publication: other_waived_pub
    
        create :internal_publication_waiver,
               authorship: waived_auth
        create :internal_publication_waiver,
               authorship: other_waived_auth
        authenticate_as(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { post :create, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "returns 404" do
          expect { post :create, params: {id: oa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "returns 404" do
          expect { post :create, params: {id: uoa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "returns 404" do
          expect { post :create, params: {id: uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "returns 404" do
          expect { post :create, params: {id: other_uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication for which the user has waived open access" do
        it "returns 404" do
          expect { post :create, params: {id: waived_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication for which another user has waived open access" do
        it "returns 404" do
          expect { post :create, params: {id: other_waived_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and is not open access" do
        it "sets the timestamp on the user's authorship of the publication" do
          post :create, params: {id: pub.id}
          expect(auth.reload.scholarsphere_uploaded_at).to eq now
        end
          
        it "redirects to the ScholarSphere website" do
          post :create, params: {id: pub.id}
          expect(response).to redirect_to 'https://scholarsphere.psu.edu/concern/generic_works/new'
        end
      end
    end
  end
end
