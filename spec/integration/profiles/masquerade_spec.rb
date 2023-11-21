# frozen_string_literal: true

require 'integration/integration_spec_helper'

describe 'an admin masqerading as another user', type: :feature do
  let!(:user) { create(:user,
                       :with_psu_identity,
                       webaccess_id: 'abc123',
                       first_name: 'Bob',
                       last_name: 'Testuser') }

  before { authenticate_admin_user }

  it 'allows admin to "become" and "unbecome" another user' do
    visit profile_path(user.webaccess_id)
    click_on 'Become this user'
    click_on "Unbecome #{user.webaccess_id}"
    click_on 'Become this user'
    click_on 'Manage my profile'
    click_on "Stop being #{user.webaccess_id}"
    expect(page).to have_button 'Become this user'
  end
end
