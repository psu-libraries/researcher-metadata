require 'integration/integration_spec_helper'

feature 'Publications Admin', type: :feature do
  let!(:publication) { create(:publication, title: 'First Publication Title') }
  scenario 'index' do
    visit 'admin/publication'
    expect(page).to have_content 'List of Publications'
    expect(page).to have_content 'First Publication Title'
  end
end
