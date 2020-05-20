require 'component/component_spec_helper'

describe OrcidAccessTokensController, type: :controller do

  describe '#new' do
    context "when the user is authenticated" do
      let!(:user) { create :user, orcid_access_token: token }
      before { authenticate_as(user) }

      context "when the user already has an ORCID access token" do
        let(:token) { "abc123" }

        it "sets a flash message" do
          get :new

          expect(flash[:notice]).to eq I18n.t('profile.orcid_access_tokens.new.already_linked')
        end

        it "redirects back to the profile bio page" do
          get :new

          expect(response).to redirect_to profile_bio_path
        end
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        get :new

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#create' do
    context "when the user is authenticated" do
      let!(:user) { create :user }
      before { authenticate_as(user) }
      
      xit
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        post :create

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
