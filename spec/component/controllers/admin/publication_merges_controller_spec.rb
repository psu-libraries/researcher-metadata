# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe Admin::PublicationMergesController, type: :controller do
  let!(:group) { create :duplicate_publication_group }
  let!(:pub1) { create :publication, duplicate_group: group }
  let!(:pub2) { create :publication, duplicate_group: group }

  describe '#create' do
    let(:perform_request) do
      post :create, params: { duplicate_publication_group_id: 1,
                              selected_publication_ids: [2],
                              merge_target_publication_id: 3 }
    end

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated as an admin' do
      before do
        user = User.new(is_admin: true)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to the given duplicate publication group' do
        post :create, params: { duplicate_publication_group_id: group.id,
                                selected_publication_ids: [pub1.id],
                                merge_target_publication_id: pub2.id }

        expect(response).to redirect_to show_path(model_name: :duplicate_publication_group, id: group.id)
      end
    end

    context 'when authenticated as a non-admin user' do
      before do
        user = User.new(is_admin: false)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects back to the home page with an error message' do
        post :create, params: { duplicate_publication_group_id: group.id,
                                selected_publication_ids: [pub1.id],
                                merge_target_publication_id: pub2.id }

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end
  end
end
