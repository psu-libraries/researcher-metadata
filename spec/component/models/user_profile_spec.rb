require 'component/component_spec_helper'

describe UserProfile do
  let!(:user) { create :user,
                       webaccess_id: 'abc123',
                       ai_title: 'test title',
                       ai_website: 'www.test.com',
                       ai_bio: 'test bio' }

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
end
