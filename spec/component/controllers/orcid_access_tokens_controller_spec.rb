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

      context "when the user does not have an ORCID access token" do
        let(:token) { nil }
        
        it "redirects to the start of the ORCID Oauth page" do
          get :new
          
          expect(response).to redirect_to "https://sandbox.orcid.org/oauth/authorize?client_id=test&response_type=code&scope=/activities/update&redirect_uri=http://test.host/orcid_access_token"
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
      let(:client) { double 'ORCID Oauth client' }
      let(:response) { double 'ORCID Oauth response',
                              code: code,
                              content_type: nil }

      before do
        allow(OrcidOauthClient).to receive(:new).and_return(client)
        allow(client).to receive(:create_token).with('abc123').and_return(response)
        allow(response).to receive(:[]).with('access_token').and_return('xyz789')
        allow(response).to receive(:[]).with('refresh_token').and_return('def456')
        allow(response).to receive(:[]).with('expires_in').and_return(20000000)
        allow(response).to receive(:[]).with('scope').and_return('/authenticate')
        allow(response).to receive(:[]).with('orcid').and_return('0000-0001-2345-6789')
      end

      let!(:user) { create :user }
      before do
        authenticate_as(user)
        post :create, params: {code: 'abc123'}
      end
      
      context "when the request to create an access token is successful" do
        let(:code) { 200 }

        it "saves the data from the response" do
          expect(user.orcid_access_token).to eq 'xyz789'
          expect(user.orcid_refresh_token).to eq 'def456'
          expect(user.orcid_access_token_expires_in).to eq 20000000
          expect(user.orcid_access_token_scope).to eq '/authenticate'
          expect(user.authenticated_orcid_identifier).to eq '0000-0001-2345-6789'
        end

        it "sets a flash message" do
          expect(flash[:notice]).to eq I18n.t('profile.orcid_access_tokens.create.success')
        end

        it "redirects back to the profile bio page" do
          expect(response).to redirect_to profile_bio_path
        end
      end

      context "when the request to create an access token fails" do
        let(:code) { 400 }

        it "sets a flash message" do
          expect(flash[:alert]).to eq I18n.t('profile.orcid_access_tokens.create.error')
        end

        it "redirects back to the profile bio page" do
          expect(response).to redirect_to profile_bio_path
        end
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        post :create

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
