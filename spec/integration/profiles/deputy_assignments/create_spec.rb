# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'Creating a new proxy', type: :feature do
  context 'when not logged in' do
    before { visit deputy_assignments_path }

    it 'is not allowed' do
      expect(page).not_to have_current_path(deputy_assignments_path)
    end
  end

  context 'when logged in', :vcr do
    let!(:user) { create :user }

    before do
      authenticate_as(user)
      visit deputy_assignments_path
    end

    context 'when all goes well' do
      it 'creates a DeputyAssignment' do
        fill_in 'new_deputy_assignment_form_deputy_webaccess_id', with: 'agw13'
        click_button I18n.t!('helpers.submit.new_deputy_assignment_form.create')

        da = DeputyAssignment.active.where(primary: user).last
        expect(da).to be_present
        expect(da.deputy.webaccess_id).to eq 'agw13'
        expect(page).to have_content da.deputy.name
      end
    end

    context 'when there is an error' do
      before do
        existing_user = create :user, webaccess_id: 'agw13'
        _existing_da = create :deputy_assignment, :active, :confirmed, primary: user, deputy: existing_user
      end

      it 'shows the errors' do
        fill_in 'new_deputy_assignment_form_deputy_webaccess_id', with: 'agw13'
        click_button I18n.t!('helpers.submit.new_deputy_assignment_form.create')

        expect(find_field('new_deputy_assignment_form_deputy_webaccess_id').value).to eq 'agw13'
        expect(page).to have_selector('.invalid-feedback')
      end
    end
  end
end
