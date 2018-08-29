require 'component/component_spec_helper'

describe CustomAdmin::DuplicatePublicationGroupingsController, type: :controller do
  let!(:user) { create :user }
  describe '#create' do
    context "when authenticated as an admin" do
      before { authenticate_admin_user }
      it "redirects to the user detail page" do
        post :create, params: { user_id: user.id }

        expect(response).to redirect_to show_path(model_name: :user, id: user.id)
      end
    end

    context "when not authenticated as an admin" do
      it "redirects to the admin sign in page" do
        post :create, params: { user_id: user.id }

        expect(response).to redirect_to new_user_session_path
      end

      it "shows an error message" do
        post :create, params: { user_id: user.id }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end