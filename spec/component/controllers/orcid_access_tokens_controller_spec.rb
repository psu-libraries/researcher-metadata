require 'component/component_spec_helper'

describe OrcidAccessTokensController, type: :controller do
  describe '#new' do
    context 'when the user is authenticated' do
      let!(:user) { create :user, orcid_access_token: token }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user already has an ORCID access token' do
        let(:token) { 'abc123' }

        it 'sets a flash message' do
          post :new

          expect(flash[:notice]).to eq I18n.t('profile.orcid_access_tokens.new.already_linked')
        end

        it 'redirects back to the profile bio page' do
          post :new

          expect(response).to redirect_to profile_bio_path
        end
      end

      context 'when the user does not have an ORCID access token' do
        let(:token) { nil }

        it 'redirects to the start of the ORCID Oauth page' do
          post :new

          expect(response).to redirect_to 'https://sandbox.orcid.org/oauth/authorize?client_id=test&response_type=code&scope=/read-limited%20/activities/update%20/person/update&redirect_uri=http://test.host/orcid_access_token'
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'redirects to the home page' do
        post :new

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        post :new

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end

  describe '#create' do
    context 'when the user is authenticated' do
      let(:client) { double 'ORCID Oauth client' }
      let!(:user) { create :user }
      let(:response) { double 'ORCID Oauth response',
                              code: response_code,
                              content_type: nil,
                              body: nil }
      let(:parsed_response) { {} }
      let(:response_code) { 200 }

      before do
        allow(OrcidOauthClient).to receive(:new).and_return(client)
        allow(client).to receive(:create_token).with('abc123').and_return(response)
        allow(response).to receive(:[]).with('access_token').and_return('xyz789')
        allow(response).to receive(:[]).with('refresh_token').and_return('def456')
        allow(response).to receive(:[]).with('expires_in').and_return(20000000)
        allow(response).to receive(:[]).with('scope').and_return('/authenticate')
        allow(response).to receive(:[]).with('orcid').and_return('0000-0001-2345-6789')
      end

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        post :create, params: { code: 'abc123' }
      end

      context 'when ORCID redirects back with an access_denied error' do
        before { get :create, params: { error: 'access_denied' } }

        it 'sets a flash message' do
          expect(flash.now[:alert]).to eq I18n.t('profile.orcid_access_tokens.create.authorization_denied')
        end

        it 'renders the create template' do
          expect(response).to render_template('create')
        end
      end

      context 'when ORCID redirects back with no error' do
        before { get :create, params: { code: 'abc123' } }

        context 'when the request to create an access token is successful' do
          it 'saves the data from the response' do
            expect(user.orcid_access_token).to eq 'xyz789'
            expect(user.orcid_refresh_token).to eq 'def456'
            expect(user.orcid_access_token_expires_in).to eq 20000000
            expect(user.orcid_access_token_scope).to eq '/authenticate'
            expect(user.authenticated_orcid_identifier).to eq '0000-0001-2345-6789'
          end

          it 'sets a flash message' do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_access_tokens.create.success')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to profile_bio_path
          end
        end

        context 'when the request to create an access token fails' do
          let(:response_code) { 500 }

          it 'sets a flash message' do
            expect(flash[:alert]).to eq I18n.t('profile.orcid_access_tokens.create.error')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to profile_bio_path
          end
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'redirects to the home page' do
        get :create

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        get :create

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
