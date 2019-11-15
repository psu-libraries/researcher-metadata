require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "visiting the page to edit the open acess status of a publication" do
  let(:user) { create :user }
  let(:pub) { create :publication, title: 'Test Publication' }
  let(:other_pub) { create :publication }
  let(:oa_pub) { create :publication, open_access_url: 'a URL' }

  before do
    create :authorship, user: user, publication: pub
    create :authorship, user: user, publication: oa_pub
  end

  context "when the user is not signed in" do
    before { visit edit_open_access_publication_path(pub) }

    it "does not allow them to visit the page" do
      expect(page.current_path).not_to eq edit_open_access_publication_path(pub)
    end
  end

  context "when the user is signed in" do
    before { authenticate_as(user) }

    context "when requesting a publication that belongs to the user" do
      before { visit edit_open_access_publication_path(pub) }
      it_behaves_like "a profile management page"
      
      it "shows the title of the publication" do
        expect(page).to have_content "Test Publication"
      end
    end

    context "when requesting a publication that belongs to the user and has an open access URL" do
      it "returns 404" do
        expect { visit edit_open_access_publication_path(oa_pub) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "when requesting a publication that does not belong to the user" do
      it "returns 404" do
        expect { visit edit_open_access_publication_path(other_pub) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
