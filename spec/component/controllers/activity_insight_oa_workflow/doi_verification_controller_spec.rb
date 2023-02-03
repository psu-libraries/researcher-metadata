# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe ActivityInsightOaWorkflow::DOIVerificationController, type: :controller do
  let!(:user) { create(:user, is_admin: false) }

  describe '#index' do
    let(:perform_request) { get :index }

    it_behaves_like 'an unauthenticated controller'

    context 'when the user is not an admin' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to the home page and sets flash message' do
        expect(perform_request).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end

    context 'when the user is an admin' do
      before do
        user.update is_admin: true
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'renders the DOIVerification index page' do
        expect(perform_request).to render_template(:index)
      end
    end
  end
end
