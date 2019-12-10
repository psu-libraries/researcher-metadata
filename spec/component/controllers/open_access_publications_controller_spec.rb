require 'component/component_spec_helper'

describe OpenAccessPublicationsController, type: :controller do

  describe '#edit' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        get :edit, params: {id: 1}

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
      let!(:auth) { create :authorship, user: user, publication: pub }

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

        authenticate_as(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { get :edit, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "returns 404" do
          expect { get :edit, params: {id: oa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "returns 404" do
          expect { get :edit, params: {id: uoa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "returns 404" do
          expect { get :edit, params: {id: uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "returns 404" do
          expect { get :edit, params: {id: other_uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and is not open access" do          
        it "returns 200 OK" do
          get :edit, params: {id: pub.id}
          expect(response.code).to eq "200"
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
      let!(:user) { create :user }
      let!(:other_user) { create :user }
      let!(:pub) { create :publication }
      let!(:oa_pub) { create :publication, open_access_url: "url" }
      let!(:uoa_pub) { create :publication, user_submitted_open_access_url: "url" }
      let!(:other_pub) { create :publication }
      let!(:uploaded_pub) { create :publication }
      let!(:other_uploaded_pub) { create :publication }
      let!(:auth) { create :authorship, user: user, publication: pub }

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

        authenticate_as(user)
      end

      context "when given the ID for a publication that does not belong to the user" do
        it "returns 404" do
          expect { patch :update, params: {id: other_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has an open access URL" do
        it "returns 404" do
          expect { patch :update, params: {id: oa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that belongs to the user and has a user-submitted open access URL" do
        it "returns 404" do
          expect { patch :update, params: {id: uoa_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by the user" do
        it "returns 404" do
          expect { patch :update, params: {id: uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a publication that has already been uploaded to ScholarSphere by another user" do
        it "returns 404" do
          expect { patch :update, params: {id: other_uploaded_pub.id} }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
