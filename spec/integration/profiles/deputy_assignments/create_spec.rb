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
    let!(:user) { create(:user, webaccess_id: 'abc123') }

    before do
      authenticate_as(user)
      visit deputy_assignments_path
    end

    context 'when all goes well' do
      before do
        fill_in 'new_deputy_assignment_form_deputy_webaccess_id', with: 'ajk5603'
        click_button I18n.t!('helpers.submit.new_deputy_assignment_form.create')
      end

      it 'creates a DeputyAssignment' do
        da = DeputyAssignment.active.where(primary: user).last
        expect(da).to be_present
        expect(da.deputy.webaccess_id).to eq 'ajk5603'
        expect(page).to have_content da.deputy.name
      end

      it 'emails the deputy of the assignment' do
        open_email('ajk5603@psu.edu')
        expect(current_email.subject).to match(/proxy assignment request/i)
      end
    end

    context 'when there is an error' do
      before do
        existing_user = create(:user, webaccess_id: 'agw13')
        _existing_da = create(:deputy_assignment, :active, :confirmed, primary: user, deputy: existing_user)
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
