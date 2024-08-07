# frozen_string_literal: true

require 'component/component_spec_helper'

describe API::V1::UserProfileSerializer do
  let(:profile) { double 'user profile',
                         id: 1,
                         name: 'test name',
                         organization_name: 'test org',
                         title: 'test title',
                         email: 'test@email.com',
                         office_location: 'test office',
                         office_phone_number: '555-555-5555',
                         personal_website: 'website.org',
                         total_scopus_citations: 100,
                         scopus_h_index: 25,
                         pure_profile_url: 'pure_profile',
                         bio: 'test bio',
                         teaching_interests: 'test teaching interests',
                         research_interests: 'test research interests',
                         publications: ['pub1', 'pub2'],
                         other_publications: { 'Letters' => ['letter1', 'letter2'], 'Books' => ['book1'] },
                         grants: ['grant1', 'grant2'],
                         presentations: ['presentation1', 'presentation2'],
                         performances: ['performance1', 'performance2'],
                         master_advising_roles: ['m_role1', 'm_role2'],
                         phd_advising_roles: ['p_role1', 'p_role2'],
                         news_stories: ['story1', 'story2'],
                         education_history: ['history1', 'history2'],
                         orcid_identifier: 'orcid' }

  describe 'data attributes' do
    subject { serialized_data_attributes(profile) }

    context 'when the user is active' do
      before { allow(profile).to receive(:active?).and_return(true) }

      it { is_expected.to include(bio: 'test bio') }
      it { is_expected.to include(bio: 'test bio') }
      it { is_expected.to include(education_history: ['history1', 'history2']) }
      it { is_expected.to include(email: 'test@email.com') }
      it { is_expected.to include(grants: ['grant1', 'grant2']) }
      it { is_expected.to include(master_advising_roles: ['m_role1', 'm_role2']) }
      it { is_expected.to include(name: 'test name') }
      it { is_expected.to include(news_stories: ['story1', 'story2']) }
      it { is_expected.to include(office_location: 'test office') }
      it { is_expected.to include(office_phone_number: '555-555-5555') }
      it { is_expected.to include(orcid_identifier: 'orcid') }
      it { is_expected.to include(organization_name: 'test org') }
      it { is_expected.to include(other_publications: { 'Letters' => ['letter1', 'letter2'], 'Books' => ['book1'] }) }
      it { is_expected.to include(performances: ['performance1', 'performance2']) }
      it { is_expected.to include(personal_website: 'website.org') }
      it { is_expected.to include(phd_advising_roles: ['p_role1', 'p_role2']) }
      it { is_expected.to include(presentations: ['presentation1', 'presentation2']) }
      it { is_expected.to include(publications: ['pub1', 'pub2']) }
      it { is_expected.to include(pure_profile_url: 'pure_profile') }
      it { is_expected.to include(research_interests: 'test research interests') }
      it { is_expected.to include(scopus_h_index: 25) }
      it { is_expected.to include(teaching_interests: 'test teaching interests') }
      it { is_expected.to include(title: 'test title') }
      it { is_expected.to include(total_scopus_citations: 100) }
    end

    context 'when the user is inactive' do
      before { allow(profile).to receive(:active?).and_return(false) }

      it { is_expected.not_to include(email: 'test@email.com') }
    end
  end
end
