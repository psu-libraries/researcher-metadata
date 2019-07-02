require 'component/component_spec_helper'

describe AuthorshipsController, type: :controller do

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

      let!(:authorship) { create :authorship,
                                 user: user,
                                 visible_in_profile: false,
                                 author_number: 1 }
      let!(:other_authorship) { create :authorship, user: other_user }

      before { authenticate_as(user) }

      context "when given the ID for an authorship that does not belong to the user" do
        it "returns 404" do
          expect { put :update, params: {id: other_authorship.id.to_s} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given the ID for an authorship that belongs to the user" do
        context "when given a permitted param" do
          it "updates the authorship" do
            put :update, params: {id: authorship.id.to_s, authorship: {visible_in_profile: true}}

            expect(authorship.reload.visible_in_profile).to eq true
          end
        end

        context "when given a param that is not permitted" do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: {id: authorship.id.to_s, authorship: {author_number: 2}}

            expect(authorship.reload.author_number).to eq 1
          end
        end
      end
    end
  end

  describe '#sort' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        put :sort

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:authorship_1) { create :authorship, user: user }
      let!(:authorship_2) { create :authorship, user: user }
      let!(:authorship_3) { create :authorship, user: user }
      let!(:authorship_4) { create :authorship, user: user }
      let!(:other_authorship) { create :authorship, user: other_user }

      before { authenticate_as(user) }

      context "when given no authorship IDs" do
        it "returns 404" do
          expect { put :sort }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given an ID for an authorship that does not belong to the user" do
        it "returns 404" do
          expect { put :sort, params: {authorship: [authorship_1.id.to_s,
                                                    authorship_2.id.to_s,
                                                    other_authorship.id.to_s]} }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when given IDs for authorships that do belong to the user" do
        it "updates each authorship's profile position with the order in which the ID was given" do
          put :sort, params: {authorship: [authorship_2.id.to_s,
                                           authorship_3.id.to_s,
                                           authorship_1.id.to_s]}

          expect(authorship_1.reload.position_in_profile).to eq 3
          expect(authorship_2.reload.position_in_profile).to eq 1
          expect(authorship_3.reload.position_in_profile).to eq 2
          expect(authorship_4.reload.position_in_profile).to eq nil
        end
      end
    end
  end
end
