# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe Admin::MasqueradeController, type: :controller do
  describe 'POST #become' do
    let(:perform_request) { post :become, params: { user_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:pretender) { create(:user) }

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
  end

  describe 'POST #unbecome' do
    let(:perform_request) { post :unbecome, params: { user_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:pretender) { create(:user) }

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
  end
end
