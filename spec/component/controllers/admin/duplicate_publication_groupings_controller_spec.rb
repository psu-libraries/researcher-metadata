# frozen_string_literal: true

require 'component/component_spec_helper'

describe Admin::DuplicatePublicationGroupingsController, type: :controller do
  let!(:user) { create :user }

  describe '#create' do
    context 'when authenticated as an admin' do
      before do
        user = User.new(is_admin: true)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to the user detail page' do
        post :create, params: { user_id: user.id }

        expect(response).to redirect_to show_path(model_name: :user, id: user.id)
      end
    end

    context 'when authenticated as a non-admin user' do
      before do
        user = User.new(is_admin: false)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects back to the home page with an error message' do
        post :create, params: { user_id: user.id }

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end

    context 'when not authenticated' do
      it 'redirects to the home page' do
        post :create, params: { user_id: user.id }

        expect(response).to redirect_to root_path
      end

      it 'shows an error message' do
        post :create, params: { user_id: user.id }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
