# frozen_string_literal: true

require 'component/component_spec_helper'

describe Admin::MasqueradeController, type: :controller do
  describe 'POST #become' do
    let(:pretender) { create(:user) }

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user is an admin' do
        let(:user) { create(:user, is_admin: true) }

        it 'redirects to user profile' do
          post :become, params: { user_id: pretender.id }

          expect(session[:pretend_user_id]).to eq(pretender.id)
          expect(session[:admin_user_id]).to eq(user.id)
          expect(response).to redirect_to(profile_path(pretender.webaccess_id))
        end
      end

      context 'when the user is not an admin' do
        let(:user) { create(:user, is_admin: false) }

        it 'redirects back to the home page with an error message' do
          post :become, params: { user_id: pretender.id }

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
        end
      end
    end

    context 'when not authenticated' do
      it 'redirects to the admin home page' do
        post :become, params: { user_id: pretender.id }

        expect(response).to redirect_to root_path
      end

      it 'shows an error message' do
        post :become, params: { user_id: pretender.id }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end

  describe 'POST #unbecome' do
    let(:pretender) { create(:user) }

    context 'when authenticated' do
      before do
        session[:pretend_user_id] = pretender.id
        session[:admin_user_id] = user.id
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user is an admin' do
        let(:user) { create(:user, is_admin: true) }

        it 'redirects to user profile' do
          expect(session[:pretend_user_id]).to eq(pretender.id)

          post :unbecome, params: { user_id: pretender.id }

          expect(session[:pretend_user_id]).to be_nil
          expect(session[:admin_user_id]).to be_nil
          expect(response).to redirect_to(profile_path(pretender.webaccess_id))
        end
      end

      context 'when the user is not an admin' do
        let(:user) { create(:user, is_admin: false) }

        it 'redirects back to the home page with an error message' do
          post :unbecome, params: { user_id: pretender.id }

          expect(session[:pretend_user_id]).to eq(pretender.id)
          expect(session[:admin_user_id]).to eq(user.id)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
        end
      end
    end

    context 'when not authenticated' do
      it 'redirects to the admin home page' do
        post :unbecome, params: { user_id: pretender.id }

        expect(response).to redirect_to root_path
      end

      it 'shows an error message' do
        post :unbecome, params: { user_id: pretender.id }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
