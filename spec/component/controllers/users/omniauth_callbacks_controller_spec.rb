# frozen_string_literal: true

require 'component/component_spec_helper'

describe Users::OmniauthCallbacksController, type: :controller do
  let(:oauth_response) { double 'psu oauth response' }
  let(:user) { build :user }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:azure_oauth] = oauth_response

    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_oauth]

    allow(User).to receive(:from_omniauth)
      .with(oauth_response)
      .and_return(user)
  end

  describe '#azure_oauth' do
    context 'when a user is found' do
      before do
        session['user_return_to'] = profile_bio_path
        get :azure_oauth
      end

      it 'signs in the user' do
        expect(warden.authenticated?(:user)).to be true
      end

      it 'sets current_user' do
        expect(controller.current_user).to eq user
      end

      it 'sets a flash message' do
        expect(flash[:notice]).to eq I18n.t('devise.omniauth_callbacks.success', kind: 'Penn State')
      end

      it 'redirects the user to their destination' do
        expect(response).to redirect_to profile_bio_path
      end
    end

    context 'when a user is not found' do
      before do
        allow(User).to receive(:from_omniauth)
          .with(oauth_response)
          .and_raise(User::OmniauthError)
      end

      it 'redirects to the home page' do
        get :azure_oauth
        expect(response).to redirect_to root_path
      end

      it 'shows an error message' do
        get :azure_oauth
        expect(flash[:alert]).to eq I18n.t('omniauth.user_not_found')
      end

      context 'when the user had last tried to visit the profile management interface' do
        before { session['user_return_to'] = profile_bio_path }

        it 'sends the user to an external site' do
          get :azure_oauth
          expect(response).to redirect_to 'https://sites.psu.edu/openaccess/waiver-form/'
        end
      end

      context 'when the user had last tried to visit the new external publication waiver form' do
        before { session['user_return_to'] = new_external_publication_waiver_path }

        it 'sends the user to an external site' do
          get :azure_oauth
          expect(response).to redirect_to 'https://sites.psu.edu/openaccess/waiver-form/'
        end
      end
    end
  end
end
