# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe EducationHistoryItemsController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe '#update' do
    let(:perform_request) { put :update, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let!(:user) { create(:user) }
      let!(:other_user) { create(:user) }

      let!(:education_history_item) { create(:education_history_item,
                                             user: user,
                                             visible_in_profile: false,
                                             degree: 'existing degree') }
      let!(:other_education_history_item) { create(:education_history_item, user: other_user) }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for an education history item that does not belong to the user' do
        it 'returns 404' do
          expect { put :update, params: { id: other_education_history_item.id.to_s } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for an education history item that belongs to the user' do
        context 'when given a permitted param' do
          it 'updates the education history item' do
            put :update, params: { id: education_history_item.id.to_s, education_history_item: { visible_in_profile: false } }

            expect(education_history_item.reload.visible_in_profile).to be false
          end
        end

        context 'when given a param that is not permitted' do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: { id: education_history_item.id.to_s, education_history_item: { degree: 'new degree' } }

            expect(education_history_item.reload.degree).to eq 'existing degree'
          end
        end
      end
    end
  end
end
