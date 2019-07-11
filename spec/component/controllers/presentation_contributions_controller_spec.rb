require 'component/component_spec_helper'

describe PresentationContributionsController, type: :controller do

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

      let!(:contribution) { create :presentation_contribution,
                                   user: user,
                                   visible_in_profile: false,
                                   role: 'existing role' }
      let!(:other_contribution) { create :presentation_contribution, user: other_user }

      before { authenticate_as(user) }

      context "when given the ID for a presentation contribution that does not belong to the user" do
        it "returns 404" do
          expect { put :update, params: {id: other_contribution.id.to_s} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for a presentation contribution that belongs to the user" do
        context "when given a permitted param" do
          it "updates the presentation contribution" do
            put :update, params: {id: contribution.id.to_s, presentation_contribution: {visible_in_profile: true}}

            expect(contribution.reload.visible_in_profile).to eq true
          end
        end

        context "when given a param that is not permitted" do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: {id: contribution.id.to_s, presentation_contribution: {role: 'new role'}}

            expect(contribution.reload.role).to eq 'existing role'
          end
        end
      end
    end
  end
end
