# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'Destroying a Proxy', type: :feature do
  context 'when not logged in' do
    before { visit deputy_assignments_path }

    it 'is not allowed' do
      expect(page).to have_no_current_path(deputy_assignments_path)
    end
  end

  context 'when logged in' do
    before do
      authenticate_as(user)
      visit deputy_assignments_path

      within "##{dom_id(deputy_assignment)}" do
        click_on destroy_button
      end
    end

    context 'when the DeputyAssignment is deactivated, but not destroyed in the db' do
      let!(:deputy_assignment) { create(:deputy_assignment, :confirmed, :active) }
      let!(:user) { deputy_assignment.primary }
      let!(:other) { deputy_assignment.deputy }
      let(:destroy_button) { I18n.t!('view_component.deputy_assignment_component.delete_as_primary') }

      it 'allows the deputy assignment to be deactivated' do
        expect(deputy_assignment.reload).not_to be_active
        expect(page).to have_no_css "##{dom_id(deputy_assignment)}"
      end

      it 'emails the other user' do
        open_email("#{other.webaccess_id}@psu.edu")
        expect(current_email.subject).to match(/proxy status revoked/i)
      end
    end

    context 'when the DeputyAssignment is actually destroyed in the db' do
      let!(:deputy_assignment) { create(:deputy_assignment, :unconfirmed, :active) }
      let!(:user) { deputy_assignment.deputy }
      let!(:other) { deputy_assignment.primary }
      let(:destroy_button) { I18n.t!('view_component.deputy_assignment_component.delete_as_deputy_unconfirmed') }

      it 'allows the deputy assignment to be destroyed' do
        expect { deputy_assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(page).to have_no_css "##{dom_id(deputy_assignment)}"
      end

      it 'emails the other user' do
        open_email("#{other.webaccess_id}@psu.edu")
        expect(current_email.subject).to match(/proxy request declined/i)
      end
    end
  end
end
