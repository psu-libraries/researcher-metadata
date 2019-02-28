require 'component/component_spec_helper'

describe UserProfile do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       ai_title: 'test title',
                       ai_website: 'www.test.com',
                       ai_bio: 'test bio',
                       show_all_publications: true }

  subject(:profile) { UserProfile.new(user) }

  it { is_expected.to delegate_method(:id).to(:user) }
  it { is_expected.to delegate_method(:name).to(:user) }
  it { is_expected.to delegate_method(:office_location).to(:user) }
  it { is_expected.to delegate_method(:total_scopus_citations).to(:user) }
  it { is_expected.to delegate_method(:scopus_h_index).to(:user) }
  it { is_expected.to delegate_method(:pure_profile_url).to(:user) }

  describe '#title' do
    it "returns the given user's title from Activity Insight" do
      expect(profile.title).to eq 'test title'
    end
  end
  describe '#email' do
    it "returns the email address for the given user based on their webaccess ID" do
      expect(profile.email).to eq 'abc123@psu.edu'
    end
  end

  describe '#personal_website' do
    it "returns the given user's personal website information from Activity Insight" do
      expect(profile.personal_website).to eq 'www.test.com'
    end
  end

  describe '#bio' do
    it "returns the given user's biographical text from Activity Insight" do
      expect(profile.bio).to eq 'test bio'
    end
  end

  describe '#publications' do
    let!(:pub1) { create :publication, title: "First Publication",
                         visible: true,
                         journal_title: "Test Journal",
                         published_on: Date.new(2010, 1, 1),
                         total_scopus_citations: 4 }
    let!(:pub2) { create :publication, title: "Second Publication",
                         visible: true,
                         publisher: "Test Publisher",
                         published_on: Date.new(2015, 1, 1) }
    let!(:pub3) { create :publication, title: "Third Publication",
                         visible: true,
                         published_on: Date.new(2018, 1, 1),
                         total_scopus_citations: 5 }
    let!(:pub4) { create :publication, title: "Undated Publication",
                         visible: true }
    let!(:pub5) { create :publication,
                         title: "Invisible Publication",
                         visible: false }
    before do
      create :authorship, user: user, publication: pub1
      create :authorship, user: user, publication: pub2
      create :authorship, user: user, publication: pub3
      create :authorship, user: user, publication: pub4
      create :authorship, user: user, publication: pub5
    end

    it "returns an array of strings describing the given user's publications in order by date" do
      expect(profile.publications).to eq [
        "Undated Publication",
        "Third Publication, 2018",
        "Second Publication, Test Publisher, 2015",
        "First Publication, Test Journal, 2010"
      ]
    end
  end
end
