# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe Admin::MasqueradeController, type: :controller do
  describe 'POST #become' do
    let(:perform_request) { post :become, params: { user_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:primary) { create(:user) }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user is an admin' do
        let(:user) { create(:user, is_admin: true) }

        it 'redirects to user profile' do
          post :become, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)
          expect(response).to redirect_to(profile_path(primary.webaccess_id))
        end
      end

      context 'when the user is not an admin' do
        let(:user) { create(:user, is_admin: false) }

        it 'redirects back to the home page with an error message' do
          post :become, params: { user_id: primary.id }

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
      let(:primary) { create(:user) }

      before do
        session[MasqueradingBehaviors::SESSION_ID] = primary.id
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user is an admin' do
        let(:user) { create(:user, is_admin: true) }

        it 'redirects to user profile' do
          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)

          post :unbecome, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to be_nil
          expect(response).to redirect_to(profile_path(primary.webaccess_id))
        end
      end

      context 'when the user is not an admin' do
        let(:user) { create(:user, is_admin: false) }

        it 'redirects back to the home page with an error message' do
          post :unbecome, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
        end
      end
    end
  end
end
