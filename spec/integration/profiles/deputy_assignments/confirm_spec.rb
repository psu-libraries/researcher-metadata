# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'Confirming a Proxy', type: :feature do
  context 'when not logged in' do
    before { visit deputy_assignments_path }

    it 'is not allowed' do
      expect(page).not_to have_current_path(deputy_assignments_path)
    end
  end

  context 'when logged in' do
    let!(:user) { create :user }
    let!(:deputy_assignment) { create :deputy_assignment, :unconfirmed, :active, deputy: user }

    before do
      authenticate_as(user)
      visit deputy_assignments_path
    end

    it 'allows a pending deputy assignment to be confirmed' do
      accept_button = I18n.t!('view_component.deputy_assignment_component.accept')

      within "##{dom_id(deputy_assignment)}" do
        click_on accept_button
      end

      expect(deputy_assignment.reload).to be_confirmed

      within "##{dom_id(deputy_assignment)}" do
        expect(page).not_to have_button(accept_button)
      end
    end
  end
end
