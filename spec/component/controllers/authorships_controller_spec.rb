# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe AuthorshipsController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe '#create' do
    let(:perform_request) { post :create, params: { authorship: { publication_id: 3, author_number: 5 } } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let!(:user) { create :user }
      let(:pub) { double 'publication', id: 3, title: 'Test Title' }
      let(:service) { spy 'authorship claim service' }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        allow(Publication).to receive(:find).with('3').and_return(pub)
        allow(AuthorshipClaimService).to receive(:new).with(user, pub, '5').and_return service
      end

      it 'claims the given publication for the current user' do
        perform_request
        expect(service).to have_received(:create)
      end

      it 'sets a success message' do
        perform_request
        expect(flash[:notice]).to eq I18n.t('profile.authorships.create.success', title: 'Test Title')
      end

      it "redirects to the list of publications for the user's profile" do
        perform_request
        expect(response).to redirect_to edit_profile_publications_path
      end

      context 'when a validation error occurs' do
        let(:auth) { build :authorship }
        let(:errors) { double 'validation errors', full_messages: ['bad data!'] }

        before do
          allow(auth).to receive(:errors).and_return errors
          allow(service).to receive(:create).and_raise ActiveRecord::RecordInvalid.new(auth)
        end

        it 'sets an error message' do
          perform_request
          expect(flash[:alert]).to eq 'Validation failed: bad data!'
        end

        it 'redirects to the detail page for the given publication' do
          perform_request
          expect(response).to redirect_to publication_path(3)
        end
      end
    end
  end

  describe '#update' do
    let(:perform_request) { put :update, params: { id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:authorship) { create :authorship,
                                 user: user,
                                 visible_in_profile: false,
                                 author_number: 1 }
      let!(:other_authorship) { create :authorship, user: other_user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given the ID for an authorship that does not belong to the user' do
        it 'returns 404' do
          expect { put :update, params: { id: other_authorship.id.to_s } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given the ID for an authorship that belongs to the user' do
        context 'when given a permitted param' do
          it 'updates the authorship' do
            put :update, params: { id: authorship.id.to_s, authorship: { visible_in_profile: true } }

            expect(authorship.reload.visible_in_profile).to be true
          end

          it 'updates the timestamp on the authorship' do
            put :update, params: { id: authorship.id.to_s, authorship: { visible_in_profile: true } }

            expect(authorship.reload.updated_by_owner_at).to be_within(10.seconds).of Time.current
          end
        end

        context 'when given a param that is not permitted' do
          it "doesn't update the attribute for the non-permitted param" do
            put :update, params: { id: authorship.id.to_s, authorship: { author_number: 2 } }

            expect(authorship.reload.author_number).to eq 1
          end
        end
      end
    end
  end

  describe '#sort' do
    let(:perform_request) { put :sort }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let!(:user) { create :user }
      let!(:other_user) { create :user }

      let!(:authorship_1) { create :authorship, user: user }
      let!(:authorship_2) { create :authorship, user: user }
      let!(:authorship_3) { create :authorship, user: user }
      let!(:authorship_4) { create :authorship, user: user }
      let!(:other_authorship) { create :authorship, user: other_user }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when given no authorship IDs' do
        it 'returns 404' do
          expect { put :sort }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given an ID for an authorship that does not belong to the user' do
        it 'returns 404' do
          expect { put :sort, params: { authorship_row: [authorship_1.id.to_s,
                                                         authorship_2.id.to_s,
                                                         other_authorship.id.to_s] } }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when given IDs for authorships that do belong to the user' do
        it "updates each authorship's profile position with the order in which the ID was given" do
          put :sort, params: { authorship_row: [authorship_2.id.to_s,
                                                authorship_3.id.to_s,
                                                authorship_1.id.to_s] }

          expect(authorship_1.reload.position_in_profile).to eq 3
          expect(authorship_2.reload.position_in_profile).to eq 1
          expect(authorship_3.reload.position_in_profile).to eq 2
          expect(authorship_4.reload.position_in_profile).to be_nil
        end

        it 'updates the timestamp on each authorship that was reordered' do
          put :sort, params: { authorship_row: [authorship_2.id.to_s,
                                                authorship_3.id.to_s,
                                                authorship_1.id.to_s] }

          expect(authorship_1.reload.updated_by_owner_at).to be_within(10.seconds).of Time.current
          expect(authorship_2.reload.updated_by_owner_at).to be_within(10.seconds).of Time.current
          expect(authorship_3.reload.updated_by_owner_at).to be_within(10.seconds).of Time.current
          expect(authorship_4.reload.updated_by_owner_at).to be_nil
        end
      end
    end
  end
end
