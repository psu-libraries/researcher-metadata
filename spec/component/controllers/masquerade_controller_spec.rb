# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe MasqueradeController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe 'POST #become' do
    let(:perform_request) { post :become, params: { user_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:user) { assignment.deputy }
      let(:current_user) { CurrentUserBuilder.call(current_user: user, current_session: {}) }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      context 'when the user is a deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment) }
        let(:primary) { assignment.primary }

        it "redirects the primary user's profile" do
          post :become, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)
          expect(response).to redirect_to(profile_path(primary.webaccess_id))
        end
      end

      context 'when the user is not a deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment) }
        let(:primary) { create(:user) }

        it 'redirects back to the home page with an error message' do
          post :become, params: { user_id: primary.id }

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t!('profile.errors.not_authorized')
        end
      end

      context 'when the user is not an available deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment, :inactive) }
        let(:primary) { assignment.primary }

        it 'redirects back to the home page with an error message' do
          post :become, params: { user_id: primary.id }

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t!('profile.errors.not_authorized')
        end
      end
    end
  end

  describe 'POST #unbecome' do
    let(:perform_request) { post :unbecome, params: { user_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:user) { assignment.deputy }
      let(:current_user) { CurrentUserBuilder.call(current_user: user, current_session: session) }

      before do
        session[MasqueradingBehaviors::SESSION_ID] = primary.id
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      context 'when the user is an available deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment) }
        let(:primary) { assignment.primary }

        it 'redirects to user profile' do
          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)

          post :unbecome, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to be_nil
          expect(response).to redirect_to(profile_path(primary.webaccess_id))
        end
      end

      context 'when the user is not a deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment) }
        let(:primary) { create(:user) }

        it 'redirects back to the home page with an error message' do
          post :unbecome, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t('profile.errors.not_authorized')
        end
      end

      context 'when the user is not an available deputy of the primary user' do
        let(:assignment) { create(:deputy_assignment, :inactive) }
        let(:primary) { assignment.primary }

        it 'redirects back to the home page with an error message' do
          post :unbecome, params: { user_id: primary.id }

          expect(session[MasqueradingBehaviors::SESSION_ID]).to eq(primary.id)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq I18n.t('profile.errors.not_authorized')
        end
      end
    end
  end
end
