require 'component/component_spec_helper'

describe UserPerformancesController, type: :controller do

  describe '#update' do
    context "when not authenticated" do
      it "redirects to the home page" do
        put :update, params: {id: 1}

        expect(response).to redirect_to root_path
      end

      it "sets a flash error message" do
        put :update, params: {id: 1}

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
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

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end
      
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

  describe '#sort' do
    context "when not authenticated" do
      it "redirects to the home page" do
        put :sort

        expect(response).to redirect_to root_path
      end

      it "sets a flash error message" do
        put :sort

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end

    context "when authenticated" do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:up_1) { create :user_performance, user: user }
      let!(:up_2) { create :user_performance, user: user }
      let!(:up_3) { create :user_performance, user: user }
      let!(:up_4) { create :user_performance, user: user }
      let!(:other_up) { create :user_performance, user: other_user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "when given no user performance IDs" do
        it "returns 404" do
          expect { put :sort }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given an ID for a user performance that does not belong to the user" do
        it "returns 404" do
          expect { put :sort, params: {user_performance: [up_1.id.to_s,
                                                          up_2.id.to_s,
                                                          other_up.id.to_s]} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given IDs for user performances that do belong to the user" do
        it "updates each performances's profile position with the order in which the ID was given" do
          put :sort, params: {user_performance: [up_2.id.to_s,
                                                 up_3.id.to_s,
                                                 up_1.id.to_s]}

          expect(up_1.reload.position_in_profile).to eq 3
          expect(up_2.reload.position_in_profile).to eq 1
          expect(up_3.reload.position_in_profile).to eq 2
          expect(up_4.reload.position_in_profile).to eq nil
        end
      end
    end
  end
end
