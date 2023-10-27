# frozen_string_literal: true

shared_examples_for 'a page with the admin layout' do
  it 'shows the correct navigation links' do
    within '.sidebar' do
      expect(page).to have_link 'Duplicate publication groups'
      expect(page).to have_link 'ETDs'
      expect(page).to have_link 'Organizations'
      expect(page).to have_link 'Presentations'
      expect(page).to have_link 'Publications'
      expect(page).to have_link 'Performances'
      expect(page).to have_link 'Users'
      expect(page).to have_link 'Grants'
      expect(page).to have_link 'Internal publication waivers'
      expect(page).to have_link 'External publication waivers'
      expect(page).to have_link 'Email errors'
      expect(page).to have_link 'Statistics snapshots'
      expect(page).to have_link 'Publishers'
      expect(page).to have_link 'Journals'
      expect(page).to have_link 'Scholarsphere work deposits'
      expect(page).to have_link 'Authorships'
    end

    expect(page).to have_link 'Dashboard'
    expect(page).to have_link 'Home', href: root_path
    expect(page).to have_link 'Log out', href: destroy_user_session_path
    expect(page).to have_link 'Activity Insight Open Access Workflow'
  end
end
