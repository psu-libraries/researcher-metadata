require 'component/component_spec_helper'

describe CustomAdmin::PublicationMergesController, type: :controller do
  let!(:group) { create :duplicate_publication_group }
  let!(:pub1) { create :publication, duplicate_group: group }
  let!(:pub2) { create :publication, duplicate_group: group }

  describe '#create' do
    context "when authenticated as an admin" do
      before { authenticate_admin_user }
      it "redirects to the given duplicate publication group" do
        post :create, params: {duplicate_publication_group_id: group.id,
                               selected_publication_ids: [pub1.id],
                               merge_target_publication_id: pub2.id}

        expect(response).to redirect_to show_path(model_name: :duplicate_publication_group, id: group.id)
      end
    end

    context "when authenticated as a non-admin user" do
      before { authenticate_user }
      it "redirects back to the home page with an error message" do
        post :create, params: {duplicate_publication_group_id: group.id,
                               selected_publication_ids: [pub1.id],
                               merge_target_publication_id: pub2.id}

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end

    context "when not authenticated" do
      it "redirects to the admin sign in page" do
        post :create, params: {duplicate_publication_group_id: group.id,
                               selected_publication_ids: [pub1.id],
                               merge_target_publication_id: pub2.id}

        expect(response).to redirect_to new_user_session_path
      end

      it "shows an error message" do
        post :create, params: {duplicate_publication_group_id: group.id,
                               selected_publication_ids: [pub1.id],
                               merge_target_publication_id: pub2.id}

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end