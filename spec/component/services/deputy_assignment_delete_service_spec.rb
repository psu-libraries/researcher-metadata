# frozen_string_literal: true

require 'component/component_spec_helper'

describe DeputyAssignmentDeleteService do
  describe '.call' do
    subject(:call) { described_class.call(deputy_assignment: deputy_assignment) }

    context 'when the DeputyAssignment is active' do
      context 'when the DeputyAssignment has not been confirmed' do
        let(:deputy_assignment) { create(:deputy_assignment, :active, :unconfirmed) }

        it 'deletes the record from the database' do
          call
          expect {
            deputy_assignment.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when the DeputyAssignment has been confirmed' do
        let(:deputy_assignment) { create(:deputy_assignment, :active, :confirmed) }

        it 'marks the record as inactive' do
          call
          expect(deputy_assignment.reload).not_to be_active
        end
      end
    end

    context 'when the DeputyAssignment is not active' do
      before do
        allow(deputy_assignment).to receive(:destroy!)
        allow(deputy_assignment).to receive(:deactivate!)
      end

      context 'when the DeputyAssignment has not been confirmed' do
        let(:deputy_assignment) { create(:deputy_assignment, :inactive, :unconfirmed) }

        it 'does nothing' do
          call
          expect(deputy_assignment).not_to have_received(:destroy!)
          expect(deputy_assignment).not_to have_received(:deactivate!)
        end
      end

      context 'when the DeputyAssignment has been confirmed' do
        let(:deputy_assignment) { create(:deputy_assignment, :inactive, :confirmed) }

        it 'does nothing' do
          call
          expect(deputy_assignment).not_to have_received(:destroy!)
          expect(deputy_assignment).not_to have_received(:deactivate!)
        end
      end
    end
  end
end
