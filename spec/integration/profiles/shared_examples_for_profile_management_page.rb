# frozen_string_literal: true

shared_examples_for 'a profile management page' do
  def i18n(key)
    I18n.t!("layouts.manage_profile.nav.#{key}")
  end

  it 'shows the navigation menu' do
    expect(page)
      .to  have_link(i18n('public_profile'), href: profile_path(webaccess_id: user.webaccess_id))
      .and have_link(i18n('deputies'), href: deputy_assignments_path)
      .and have_link(i18n('home'), href: root_path)
      .and have_link(i18n('support'), href: 'mailto:L-FAMS@lists.psu.edu?subject=Researcher Metadata Database Profile Support')
      .and have_link(i18n('publications'), href: edit_profile_publications_path)
      .and have_link(i18n('presentations'), href: edit_profile_presentations_path)
      .and have_link(i18n('performances'), href: edit_profile_performances_path)
      .and have_link(i18n('sign_out'), href: destroy_user_session_path)
  end
end
