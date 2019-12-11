require 'integration/integration_spec_helper'
require 'integration/profiles/shared_examples_for_profile_management_page'

describe "visiting the page to submit an open access waiver for a publication" do
  let(:user) { create :user }
  let(:pub) { create :publication,
                     title: 'Test Publication',
                     abstract: 'This is the abstract.',
                     doi: 'https://doi.org/1234',
                     journal_title: 'A Prestegious Journal',
                     issue: "583",
                     volume: "971",
                     page_range: "478-483",
                     published_on: Date.new(2019, 1, 1) }
  let(:other_pub) { create :publication }
  let(:oa_pub) { create :publication, open_access_url: 'a URL' }
  let(:uoa_pub) { create :publication, user_submitted_open_access_url: 'user URL' }

  before do
    create :authorship, user: user, publication: pub
    create :authorship, user: user, publication: oa_pub
    create :authorship, user: user, publication: uoa_pub
  end

  context "when the user is not signed in" do
    before { visit new_internal_publication_waiver_path(pub) }

    it "does not allow them to visit the page" do
      expect(page.current_path).not_to eq new_internal_publication_waiver_path(pub)
    end
  end

  context "when the user is signed in" do
    before { authenticate_as(user) }

    context "when requesting a publication that belongs to the user" do
      before { visit new_internal_publication_waiver_path(pub) }
      it_behaves_like "a profile management page"
      
      it "shows the correct heading" do
        expect(page).to have_content "Open Access Waiver"
      end
      it "shows the title of the publication" do
        expect(page.find_field('Title').value).to eq "Test Publication"
      end
      it "shows the abstract of the publication" do
        expect(page.find_field('Abstract').value).to eq "This is the abstract."
      end
      it "shows the publication's DOI" do
        expect(page.find_field('Digital Object Identifier (DOI)').value).to eq "https://doi.org/1234"
      end
      it "shows the publication's journal" do
        expect(page.find_field('Journal').value).to eq "A Prestegious Journal"
      end

      it "shows a link to the ScholarSphere website" do
        expect(page).to have_link "ScholarSphere", href: "https://scholarsphere.psu.edu/"
      end
    end

    context "when requesting a publication that does not belong to the user" do
      it "returns 404" do
        expect { visit new_internal_publication_waiver_path(other_pub) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
