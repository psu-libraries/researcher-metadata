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
      let!(:pub) { create :publication }
      let!(:oa_pub) { create :publication, open_access_url: "url" }
      let!(:uoa_pub) { create :publication, user_submitted_open_access_url: "url" }
      let!(:other_pub) { create :publication }
      
      before do
        create :authorship, user: user, publication: pub
        create :authorship, user: user, publication: oa_pub
        create :authorship, user: user, publication: uoa_pub
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

      context "when given the ID for a publication that belongs to the user and is not open access" do
        it "redirects to the ScholarSphere website" do
          post :create, params: {id: pub.id}
          expect(response).to redirect_to 'https://scholarsphere.psu.edu/concern/generic_works/new'
        end
      end
    end
  end
end
