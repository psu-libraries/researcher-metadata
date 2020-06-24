require 'component/component_spec_helper'

describe CustomAdmin::PublicationWaiverLinksController, type: :controller do
  let(:waiver) { create :external_publication_waiver }

  describe '#create' do
    context "when authenticated as an admin" do
      before { authenticate_admin_user }
      xit "does something" do
        post :create, params: {external_publication_waiver_id: waiver.id}

      end
    end

    context "when authenticated as a non-admin user" do
      before { authenticate_user }
      it "redirects back to the home page with an error message" do
        post :create, params: {external_publication_waiver_id: waiver.id}

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end

    context "when not authenticated" do
      it "redirects to the admin sign in page" do
        post :create, params: {external_publication_waiver_id: waiver.id}

        expect(response).to redirect_to new_user_session_path
      end

      it "shows an error message" do
        post :create, params: {external_publication_waiver_id: waiver.id}

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end