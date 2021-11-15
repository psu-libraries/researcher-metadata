# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'Destroying a Proxy', type: :feature do
  context 'when not logged in' do
    before { visit deputy_assignments_path }

    it 'is not allowed' do
      expect(page).not_to have_current_path(deputy_assignments_path)
    end
  end

  context 'when logged in' do
    let!(:user) { deputy_assignment.primary }
    let!(:deputy_assignment) { create :deputy_assignment, :confirmed, :active }

    before do
      authenticate_as(user)
      visit deputy_assignments_path
    end

    it 'allows a pending deputy assignment to be destroyed' do
      destroy_button = I18n.t!('view_component.deputy_assignment_component.delete_as_primary')

      within "##{dom_id(deputy_assignment)}" do
        click_on destroy_button
      end

      expect(deputy_assignment.reload).not_to be_active
      expect(page).not_to have_selector "##{dom_id(deputy_assignment)}"
    end
  end
end
