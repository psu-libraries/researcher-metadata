require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

describe "grouping publications from a user's list of publications", type: :feature do
  let!(:user) { create :user }

  let!(:pub1) { create :publication, duplicate_group: group1 }
  let!(:pub2) { create :publication, duplicate_group: group1 }
  let!(:pub3) { create :publication, duplicate_group: group2 }
  let!(:pub4) { create :publication, duplicate_group: group2 }
  let!(:pub5) { create :publication }
  let!(:pub6) { create :publication }

  let(:group1) { create :duplicate_publication_group }
  let(:group2) { create :duplicate_publication_group }

  before do
    create :authorship, user: user, publication: pub1
    create :authorship, user: user, publication: pub2
    create :authorship, user: user, publication: pub3
    create :authorship, user: user, publication: pub4
    create :authorship, user: user, publication: pub5
    create :authorship, user: user, publication: pub6
  end

  context 'when the current user is an admin' do
    before do
      authenticate_admin_user
      visit rails_admin.show_path(model_name: :user, id: user.id)
    end

    describe 'selecting no publications and clicking the group button' do
      before do
        click_button 'Group Selected'
      end

      it 'redirects back to the user details page' do
        expect(page).to have_current_path rails_admin.show_path(model_name: :user, id: user.id), ignore_query: true
      end

      it 'shows an error message' do
        expect(page).to have_content I18n.t('admin.duplicate_publication_groupings.create.no_pub_error')
      end
    end

    describe 'selecting one publications and clicking the group button' do
      before do
        check "bulk_ids_#{pub1.id}"

        click_button 'Group Selected'
      end

      it 'redirects back to the user details page' do
        expect(page).to have_current_path rails_admin.show_path(model_name: :user, id: user.id), ignore_query: true
      end

      it 'shows an error message' do
        expect(page).to have_content I18n.t('admin.duplicate_publication_groupings.create.no_pub_error')
      end
    end

    describe 'selecting several publications to group and clicking the group button' do
      before do
        check "bulk_ids_#{pub1.id}"
        check "bulk_ids_#{pub2.id}"
        check "bulk_ids_#{pub3.id}"
        check "bulk_ids_#{pub4.id}"
        check "bulk_ids_#{pub5.id}"

        click_button 'Group Selected'
      end

      it 'groups all of the selected publications into the same group' do
        group = pub1.reload.duplicate_group || pub2.reload.duplicate_group

        expect(group.publications).to match_array [pub1, pub2, pub3, pub4, pub5]
      end

      it 'redirects back to the user details page' do
        expect(page).to have_current_path rails_admin.show_path(model_name: :user, id: user.id), ignore_query: true
      end

      it 'shows a success message' do
        expect(page).to have_content I18n.t('admin.duplicate_publication_groupings.create.success')
      end
    end
  end
end
