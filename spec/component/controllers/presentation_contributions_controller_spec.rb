require 'component/component_spec_helper'

describe PresentationContributionsController, type: :controller do
  describe '#update' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        put :update, params: { id: 1 }

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        put :update, params: { id: 1 }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end

    context 'when authenticated' do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:contribution) { create :presentation_contribution,
                                   user: user,
                                   visible_in_profile: false,
                                   role: 'existing role' }
      let!(:other_contribution) { create :presentation_contribution, user: other_user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for a presentation contribution that does not belong to the user' do
        it 'returns 404' do
          expect { put :update, params: { id: other_contribution.id.to_s } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for a presentation contribution that belongs to the user' do
        context 'when given a permitted param' do
          it 'updates the presentation contribution' do
            put :update, params: { id: contribution.id.to_s, presentation_contribution: { visible_in_profile: true } }

            expect(contribution.reload.visible_in_profile).to eq true
          end
        end

        context 'when given a param that is not permitted' do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: { id: contribution.id.to_s, presentation_contribution: { role: 'new role' } }

            expect(contribution.reload.role).to eq 'existing role'
          end
        end
      end
    end
  end

  describe '#sort' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        put :sort

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        put :sort

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end

    context 'when authenticated' do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:contribution_1) { create :presentation_contribution, user: user }
      let!(:contribution_2) { create :presentation_contribution, user: user }
      let!(:contribution_3) { create :presentation_contribution, user: user }
      let!(:contribution_4) { create :presentation_contribution, user: user }
      let!(:other_contribution) { create :presentation_contribution, user: other_user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given no presentation contribution IDs' do
        it 'returns 404' do
          expect { put :sort }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given an ID for a presentation contribution that does not belong to the user' do
        it 'returns 404' do
          expect { put :sort, params: { presentation_contribution: [contribution_1.id.to_s,
                                                                    contribution_2.id.to_s,
                                                                    other_contribution.id.to_s] } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given IDs for presentation contributions that do belong to the user' do
        it "updates each contribution's profile position with the order in which the ID was given" do
          put :sort, params: { presentation_contribution: [contribution_2.id.to_s,
                                                           contribution_3.id.to_s,
                                                           contribution_1.id.to_s] }

          expect(contribution_1.reload.position_in_profile).to eq 3
          expect(contribution_2.reload.position_in_profile).to eq 1
          expect(contribution_3.reload.position_in_profile).to eq 2
          expect(contribution_4.reload.position_in_profile).to eq nil
        end
      end
    end
  end
end
