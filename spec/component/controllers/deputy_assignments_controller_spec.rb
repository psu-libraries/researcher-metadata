# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe DeputyAssignmentsController, type: :controller do
  describe '#index' do
    let(:perform_request) { get :index }

    it_behaves_like 'an unauthenticated controller'
  end

  describe '#create' do
    let(:perform_request) { post :create, params: params }
    let(:params) { {
      'new_deputy_assignment_form' => { 'deputy_webaccess_id' => 'abc123' }
    } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      let(:user) { create :user }
      let(:mock_form) { instance_spy('NewDeputyAssignmentForm') }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)

        allow(NewDeputyAssignmentForm).to receive(:new).and_return(mock_form)
      end

      context 'when all is well' do
        before { allow(mock_form).to receive(:save).and_return(true) }

        it 'creates the DeputyAssignment' do
          perform_request
          expect(NewDeputyAssignmentForm).to have_received(:new).with(
            primary: user,
            deputy_webaccess_id: 'abc123'
          )

          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:notice]).to eq I18n.t!('deputy_assignments.create.success')
        end
      end

      context 'when there is an error' do
        before { allow(mock_form).to receive(:save).and_return(false) }

        it 're-renders the form' do
          perform_request
          expect(response).to render_template :index
        end
      end
    end
  end

  describe '#confirm' do
    let(:deputy_assignment) { create :deputy_assignment, :active, :unconfirmed }
    let(:perform_request) { patch :confirm, params: { id: deputy_assignment.id } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when the user is signed in as the deputy of the given deputy assigment' do
        let(:user) { deputy_assignment.deputy }

        it 'confirms the deputy assignment' do
          perform_request
          expect(deputy_assignment.reload).to be_confirmed
          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:notice]).to eq I18n.t!(
            'deputy_assignments.confirm.success',
            name: deputy_assignment.primary.name
          )
        end

        context 'when an unexpected error occurs in the confirmation process' do
          before do
            # force an invalid state
            deputy_assignment.update_column(:primary_user_id, nil)
          end

          it 'alerts the user and does not confirm the assignment' do
            expect(deputy_assignment.reload).not_to be_valid # sanity
            perform_request

            expect(deputy_assignment.reload).not_to be_confirmed
            expect(response).to redirect_to deputy_assignments_path
            expect(flash[:alert]).to eq I18n.t!('deputy_assignments.confirm.error')
          end
        end

        context 'when the given deputy assignment is inactive' do
          let(:deputy_assignment) { create :deputy_assignment, :inactive, :unconfirmed }

          it 'does not confirm the assignment' do
            expect {
              perform_request
            }.to raise_error(ActiveRecord::RecordNotFound)

            expect(deputy_assignment).not_to be_confirmed
          end
        end
      end

      context 'when the user is signed in as someone else' do
        let(:user) { deputy_assignment.primary }

        it 'does not confirm the deputy assignment' do
          expect {
            perform_request
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect(deputy_assignment).not_to be_confirmed
        end
      end
    end
  end

  describe '#destroy' do
    let(:deputy_assignment) { create :deputy_assignment, :active, :unconfirmed }
    let(:perform_request) { delete :destroy, params: { id: deputy_assignment.id } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)

        allow(DeputyAssignmentDeleteService).to receive(:call)
      end

      context 'when the current user is the primary of the deputy assignment' do
        let(:user) { deputy_assignment.primary }

        it 'deactivates the deputy assignment' do
          perform_request
          expect(DeputyAssignmentDeleteService).to have_received(:call)
          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:notice]).to eq I18n.t!('deputy_assignments.destroy.success')
        end
      end

      context 'when the current user is the deputy of the deputy assignment' do
        let(:user) { deputy_assignment.deputy }

        it 'deactivates the deputy assignment' do
          perform_request
          expect(DeputyAssignmentDeleteService).to have_received(:call)
        end
      end

      context 'when the current user is signed in as somebody else' do
        let(:user) { create :user }

        it 'does not delete the record' do
          expect {
            perform_request
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when an unexpected error happens' do
        let(:user) { deputy_assignment.primary }

        before { allow(DeputyAssignmentDeleteService).to receive(:call).and_raise(ActiveRecord::RecordNotDestroyed) }

        it 'alerts the user' do
          perform_request

          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:alert]).to eq I18n.t!('deputy_assignments.destroy.error')
        end
      end

      context 'when a different unexpected error happens' do
        let(:user) { deputy_assignment.primary }

        before { allow(DeputyAssignmentDeleteService).to receive(:call).and_raise(ActiveRecord::RecordInvalid) }

        it 'alerts the user' do
          perform_request

          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:alert]).to eq I18n.t!('deputy_assignments.destroy.error')
        end
      end
    end
  end
end
