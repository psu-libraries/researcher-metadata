require 'integration/integration_spec_helper'
require 'integration/admin/shared_examples_for_admin_page'

feature "merging the publications within a duplicate publication group", type: :feature do
  let!(:group) { create :duplicate_publication_group }

  let!(:pub1) { create :publication, duplicate_group: group }
  let!(:pub2) { create :publication, duplicate_group: group }
  let!(:pub3) { create :publication, duplicate_group: group }

  let!(:pub1_import1) { create :publication_import, publication: pub1 }
  let!(:pub2_import1) { create :publication_import, publication: pub2 }
  let!(:pub2_import2) { create :publication_import, publication: pub2 }
  let!(:pub3_import1) { create :publication_import, publication: pub3 }

  context "when viewing a duplicate publication group" do
    before do
      authenticate_admin_user
      visit rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id)
    end

    describe "clicking the button the merge the group into one of the publications in the group" do
      before { click_button "publication_#{pub3.id}_merge_button" }

      it "moves all of the imports from all of the publications in the group onto the selected publication" do
        expect(pub3.reload.imports).to match_array [pub1_import1, pub2_import1, pub2_import2, pub3_import1]
      end

      it "marks the selected publication as having been manually edited" do
        expect(pub3.reload.updated_by_user_at).not_to be_nil
      end

      it "deletes the other publications in the group" do
        expect { pub1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { pub2.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "deletes the group" do
        expect { group.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "redirects to the selected publication" do
        expect(page.current_path).to eq rails_admin.edit_path(model_name: :publication, id: pub3.id)
      end

      it "shows a success message" do
        expect(page).to have_content I18n.t('admin.publication_merges.create.success')
      end
    end
  end
end