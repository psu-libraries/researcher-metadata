require 'component/component_spec_helper'

describe API::V1::UserProfileSerializer do
  let(:profile) { double 'user profile',
                         id: 1,
                         name: 'test name',
                         title: 'test title',
                         email: 'test@email.com',
                         office_location: 'test office',
                         personal_website: 'website.org',
                         total_scopus_citations: 100,
                         scopus_h_index: 25,
                         pure_profile_url: 'pure_profile',
                         bio: 'test bio',
                         publications: ['pub1', 'pub2'] }

  describe "data attributes" do
    subject { serialized_data_attributes(profile) }
    it { is_expected.to include(name: 'test name') }
    it { is_expected.to include(title: 'test title') }
    it { is_expected.to include(email: 'test@email.com') }
    it { is_expected.to include(office_location: 'test office') }
    it { is_expected.to include(personal_website: 'website.org') }
    it { is_expected.to include(total_scopus_citations: 100) }
    it { is_expected.to include(scopus_h_index: 25) }
    it { is_expected.to include(pure_profile_url: 'pure_profile') }
    it { is_expected.to include(bio: 'test bio') }
    it { is_expected.to include(publications: ['pub1', 'pub2']) }
  end
end
