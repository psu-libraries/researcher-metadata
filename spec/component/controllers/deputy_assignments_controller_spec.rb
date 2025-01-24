# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe DeputyAssignmentsController, type: :controller do
  let(:mock_mailer) { instance_spy ActionMailer::MessageDelivery }

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
      let(:user) { create(:user) }
      let(:mock_form) { instance_spy(NewDeputyAssignmentForm) }
      let(:mock_assignment) { instance_spy(DeputyAssignment) }

      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)

        allow(NewDeputyAssignmentForm).to receive(:new).and_return(mock_form)
        allow(DeputyAssignmentsMailer).to receive(:deputy_assignment_request).and_return(mock_mailer)
      end

      context 'when all is well' do
        before do
          allow(mock_form).to receive(:save).and_return(true)
          allow(mock_form).to receive(:deputy_assignment).and_return(mock_assignment)
        end

        it 'creates the DeputyAssignment' do
          perform_request
          expect(NewDeputyAssignmentForm).to have_received(:new).with(
            primary: user,
            deputy_webaccess_id: 'abc123'
          )

          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:notice]).to eq I18n.t!('deputy_assignments.create.success')
        end

        it 'sends an email to the deputy' do
          perform_request
          expect(DeputyAssignmentsMailer).to have_received(:deputy_assignment_request).with(mock_assignment)
          expect(mock_mailer).to have_received(:deliver_now)
        end
      end

      context 'when there is an error' do
        before { allow(mock_form).to receive(:save).and_return(false) }

        it 're-renders the form' do
          perform_request
          expect(response).to render_template :index
        end

        it 'does not email anyone' do
          perform_request
          expect(DeputyAssignmentsMailer).not_to have_received(:deputy_assignment_request)
        end
      end
    end
  end

  describe '#confirm' do
    let(:deputy_assignment) { create(:deputy_assignment, :active, :unconfirmed) }
    let(:perform_request) { patch :confirm, params: { id: deputy_assignment.id } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)

        allow(DeputyAssignmentsMailer).to receive(:deputy_assignment_confirmation).and_return(mock_mailer)
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

        it 'emails the primary' do
          perform_request
          expect(DeputyAssignmentsMailer).to have_received(:deputy_assignment_confirmation).with(deputy_assignment)
          expect(mock_mailer).to have_received(:deliver_now)
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

          it 'does not email anyone' do
            perform_request
            expect(DeputyAssignmentsMailer).not_to have_received(:deputy_assignment_confirmation)
          end
        end

        context 'when the given deputy assignment is inactive' do
          let(:deputy_assignment) { create(:deputy_assignment, :inactive, :unconfirmed) }

          it 'does not confirm the assignment' do
            expect {
              perform_request
            }.to raise_error(ActiveRecord::RecordNotFound)

            expect(deputy_assignment).not_to be_confirmed
            expect(DeputyAssignmentsMailer).not_to have_received(:deputy_assignment_confirmation)
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
          expect(DeputyAssignmentsMailer).not_to have_received(:deputy_assignment_confirmation)
        end
      end
    end
  end

  describe '#destroy' do
    let(:deputy_assignment) { create(:deputy_assignment, :active, :unconfirmed) }
    let(:perform_request) { delete :destroy, params: { id: deputy_assignment.id } }

    it_behaves_like 'an unauthenticated controller'

    context 'when authenticated' do
      before do
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)

        allow(DeputyAssignmentDeleteService).to receive(:call)

        allow(DeputyAssignmentsMailer).to receive(:deputy_assignment_declination).and_return(mock_mailer)
        allow(DeputyAssignmentsMailer).to receive(:deputy_status_revoked).and_return(mock_mailer)
        allow(DeputyAssignmentsMailer).to receive(:deputy_status_ended).and_return(mock_mailer)
      end

      context 'when the current user is the primary' do
        let(:user) { deputy_assignment.primary }

        it 'deactivates/deletes the deputy assignment' do
          perform_request
          expect(DeputyAssignmentDeleteService).to have_received(:call)
          expect(response).to redirect_to deputy_assignments_path
          expect(flash[:notice]).to eq I18n.t!('deputy_assignments.destroy.success')
        end

        it 'sends the correct email' do
          perform_request
          expect(DeputyAssignmentsMailer).to have_received(:deputy_status_revoked)
          expect(mock_mailer).to have_received(:deliver_now)
        end
      end

      context 'when the current user is the deputy' do
        let(:user) { deputy_assignment.deputy }

        context 'when the deputy_assignment has been confirmed' do
          let(:deputy_assignment) { create(:deputy_assignment, :active, :confirmed) }

          it 'deactivates/deletes the deputy assignment' do
            perform_request
            expect(DeputyAssignmentDeleteService).to have_received(:call)
          end

          it 'sends the correct email' do
            perform_request
            expect(DeputyAssignmentsMailer).to have_received(:deputy_status_ended)
            expect(mock_mailer).to have_received(:deliver_now)
          end
        end

        context 'when the deputy_assignment has not been confirmed' do
          let(:deputy_assignment) { create(:deputy_assignment, :active, :unconfirmed) }

          it 'deactivates/deletes the deputy assignment' do
            perform_request
            expect(DeputyAssignmentDeleteService).to have_received(:call)
          end

          it 'sends the correct email' do
            perform_request
            expect(DeputyAssignmentsMailer).to have_received(:deputy_assignment_declination)
            expect(mock_mailer).to have_received(:deliver_now)
          end
        end
      end

      context 'when the current user is signed in as somebody else' do
        let(:user) { create(:user) }

        it 'does not delete the record' do
          expect {
            perform_request
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect(mock_mailer).not_to have_received(:deliver_now)
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

        it 'does not send any emails' do
          perform_request
          expect(mock_mailer).not_to have_received(:deliver_now)
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

        it 'does not send any emails' do
          perform_request
          expect(mock_mailer).not_to have_received(:deliver_now)
        end
      end
    end
  end
end
