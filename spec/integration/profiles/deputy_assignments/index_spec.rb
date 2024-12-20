# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'Proxies page', type: :feature do
  context 'when not logged in' do
    before { visit deputy_assignments_path }

    it 'is not allowed' do
      expect(page).to have_no_current_path(deputy_assignments_path)
    end
  end

  context 'when logged in' do
    let!(:user) { create(:user) }

    # Users who act as deputies for `user`
    let(:deputy_confirmed) { create(:user, first_name: 'Confirmed', last_name: 'Deputy') }
    let(:deputy_unconfirmed) { create(:user, first_name: 'Unconfirmed', last_name: 'Deputy') }
    let(:deputy_inactive) { create(:user, first_name: 'Inactive', last_name: 'Deputy') }

    # Users for whom `user` can act as a deputy
    let(:primary_confirmed) { create(:user, first_name: 'Confirmed', last_name: 'Primary') }
    let(:primary_unconfirmed) { create(:user, first_name: 'Unconfirmed', last_name: 'Primary') }
    let(:primary_inactive) { create(:user, first_name: 'Inactive', last_name: 'Primary') }

    before do
      create(:deputy_assignment, :active, :confirmed, primary: user, deputy: deputy_confirmed)
      create(:deputy_assignment, :active, :unconfirmed, primary: user, deputy: deputy_unconfirmed)
      create(:deputy_assignment, :inactive, :confirmed, primary: user, deputy: deputy_inactive)

      create(:deputy_assignment, :active, :confirmed, primary: primary_confirmed, deputy: user)
      create(:deputy_assignment, :active, :unconfirmed, primary: primary_unconfirmed, deputy: user)
      create(:deputy_assignment, :inactive, :confirmed, primary: primary_inactive, deputy: user)

      authenticate_as(user)
      visit deputy_assignments_path
    end

    it_behaves_like 'a profile management page'

    it 'shows all active proxy assignments' do
      expect(page).to have_content deputy_confirmed.name
      expect(page).to have_content deputy_unconfirmed.name
      expect(page).to have_link primary_confirmed.name
      expect(page).to have_content primary_unconfirmed.name
      expect(page).to have_no_link primary_unconfirmed.name

      expect(page).to have_no_content deputy_inactive
      expect(page).to have_no_content primary_inactive
    end

    describe "when link is clicked in confirmed primary's name" do
      before do
        person = instance_spy(PsuIdentity::SearchService::Person)
        allow_any_instance_of(PsuIdentity::SearchService::Client).to receive(:userid).with(primary_confirmed.webaccess_id).and_return(person) # rubocop:todo RSpec/AnyInstance
      end

      it "directs user to primary's public profile page" do
        click_link primary_confirmed.name
        expect(page).to have_current_path profile_path(primary_confirmed.webaccess_id)
      end
    end
  end
end
