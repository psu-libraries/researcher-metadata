# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe Admin::PublicationWaiverLinksController, type: :controller do
  let!(:waiver) { create(:external_publication_waiver, user: user, reason_for_waiver: 'The reason') }
  let!(:pub) { create(:publication) }
  let!(:user) { create(:user) }

  describe '#create' do
    let(:perform_request) { post :create, params: { external_publication_waiver_id: 1 } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated as an admin' do
      before do
        user = User.new(is_admin: true)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when an authorship matches the given waiver and publication' do
        let!(:auth) { create(:authorship, publication: pub, user: user) }

        context 'when a waiver is already associated with the authorship' do
          let!(:int_waiver) { create(:internal_publication_waiver, authorship: auth) }

          it 'sets a flash error message' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            expect(flash[:error]).to eq I18n.t('admin.publication_waiver_links.create.waiver_already_linked_error')
          end

          it 'redirects back to the waiver detail page' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            expect(response).to redirect_to show_path(model_name: :external_publication_waiver, id: waiver.id)
          end
        end

        context 'when no waiver is already associated with the authorship' do
          it 'creates a new internal waiver for the authorship' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            new_waiver = InternalPublicationWaiver.find_by(authorship: auth)

            expect(new_waiver.reason_for_waiver).to eq 'The reason'
          end

          it 'links the external waiver to the new internal waiver' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            new_waiver = InternalPublicationWaiver.find_by(authorship: auth)

            expect(waiver.reload.internal_publication_waiver).to eq new_waiver
          end

          it 'sets a flash success message' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            expect(flash[:success]).to eq I18n.t('admin.publication_waiver_links.create.success')
          end

          it 'redirects to the waiver list' do
            post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
            expect(response).to redirect_to index_path(model_name: :external_publication_waiver)
          end
        end
      end

      context 'when no authorship matches the given waiver and publication' do
        it 'sets a flash error message' do
          post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
          expect(flash[:error]).to eq I18n.t('admin.publication_waiver_links.create.no_authorship_error')
        end

        it 'redirects back to the waiver detail page' do
          post :create, params: { external_publication_waiver_id: waiver.id, publication_id: pub.id }
          expect(response).to redirect_to show_path(model_name: :external_publication_waiver, id: waiver.id)
        end
      end
    end

    context 'when authenticated as a non-admin user' do
      before do
        user = User.new(is_admin: false)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects back to the home page with an error message' do
        post :create, params: { external_publication_waiver_id: waiver.id }

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end
  end
end
