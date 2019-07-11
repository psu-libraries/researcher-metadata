require 'component/component_spec_helper'

describe UserPerformancesController, type: :controller do

  describe '#update' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        put :update, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:up) { create :user_performance,
                         user: user,
                         visible_in_profile: false,
                         activity_insight_id: 5 }
      let!(:other_up) { create :user_performance, user: other_user }

      before { authenticate_as(user) }

      context "when given the ID for a user performance that does not belong to the user" do
        it "returns 404" do
          expect { put :update, params: {id: other_up.id.to_s} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a user_performance that belongs to the user" do
        context "when given a permitted param" do
          it "updates the user performance" do
            put :update, params: {id: up.id.to_s, user_performance: {visible_in_profile: true}}

            expect(up.reload.visible_in_profile).to eq true
          end
        end

        context "when given a param that is not permitted" do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: {id: up.id.to_s, user_performance: {activity_insight_id: 6}}

            expect(up.reload.activity_insight_id).to eq 5
          end
        end
      end
    end
  end
end
