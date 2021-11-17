# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe PublicationsController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe '#index' do
    let(:perform_request) { get :index }

    it_behaves_like 'an unauthenticated controller'

    context 'when the user is authenticated' do
      let!(:user) { create :user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'renders the publication list' do
        expect(perform_request).to render_template(:index)
      end
    end
  end

  describe '#show' do
    let!(:pub) { create :publication }
    let(:perform_request) { get :show, params: { id: pub.id } }

    it_behaves_like 'an unauthenticated controller'

    context 'when the user is authenticated' do
      let!(:user) { create :user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'renders the publication detail view' do
        expect(perform_request).to render_template(:show)
      end
    end
  end
end
