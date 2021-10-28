# frozen_string_literal: true

require 'component/component_spec_helper'

describe API::V1::PublicationSerializer do
  let(:publication) { create :publication,
                             title: 'publication 1',
                             secondary_title: 'pub 1 subtitle',
                             journal_title: 'prestegious journal',
                             publication_type: 'Journal Article',
                             publisher_name: 'a publisher',
                             status: 'Published',
                             volume: '1',
                             issue: '2',
                             edition: '3',
                             page_range: '4-5',
                             authors_et_al: true,
                             published_on: date,
                             abstract: 'an abstract',
                             total_scopus_citations: 1000,
                             doi: 'https://doi.org/10.000/example',
                             open_access_locations: [build(:open_access_location,
                                                           source: Source::OPEN_ACCESS_BUTTON,
                                                           url: 'OA URL')],
                             journal: journal }
  let(:date) { nil }
  let(:journal) { create :journal, title: 'test journal title', publisher: publisher }
  let(:publisher) { create :publisher, name: 'test publisher name' }
  let(:u1) { create :user, webaccess_id: 'abc123' }
  let(:u2) { create :user, webaccess_id: 'xyz789' }

  describe 'data attributes' do
    subject { serialized_data_attributes(publication) }

    it { is_expected.to include(title: 'publication 1') }
    it { is_expected.to include(secondary_title: 'pub 1 subtitle') }
    it { is_expected.to include(journal_title: 'test journal title') }
    it { is_expected.to include(publication_type: 'Journal Article') }
    it { is_expected.to include(publisher: 'test publisher name') }
    it { is_expected.to include(status: 'Published') }
    it { is_expected.to include(volume: '1') }
    it { is_expected.to include(issue: '2') }
    it { is_expected.to include(edition: '3') }
    it { is_expected.to include(page_range: '4-5') }
    it { is_expected.to include(authors_et_al: true) }
    it { is_expected.to include(abstract: 'an abstract') }
    it { is_expected.to include(citation_count: 1000) }
    it { is_expected.to include(doi: 'https://doi.org/10.000/example') }
    it { is_expected.to include(preferred_open_access_url: 'OA URL') }

    context 'when the publication has a published_on date' do
      let(:date) { Date.new(2018, 8, 3) }

      it { is_expected.to include(published_on: '2018-08-03') }
    end

    context 'when the publication does not have a published_on date' do
      it { is_expected.to include(published_on: nil) }
    end

    context 'when the publication does not have contributor names' do
      it { is_expected.to include(contributors: []) }
    end

    context 'when the publication has contributor names' do
      subject { serialized_data_attributes(publication) }

      before do
        create :contributor_name, first_name: 'a', middle_name: 'b', last_name: 'c', position: 2, publication: publication, user: u1
        create :contributor_name, first_name: 'd', middle_name: 'e', last_name: 'f', position: 1, publication: publication, user: u2
        create :contributor_name, first_name: 'g', middle_name: 'h', last_name: 'i', position: 3, publication: publication, user: nil
      end

      it { expect(subject).to include(contributors: [{ first_name: 'd', middle_name: 'e', last_name: 'f', psu_user_id: 'xyz789' },
                                                     { first_name: 'a', middle_name: 'b', last_name: 'c', psu_user_id: 'abc123' },
                                                     { first_name: 'g', middle_name: 'h', last_name: 'i', psu_user_id: nil }]) }
    end

    context 'when the publication does not have imports from Pure' do
      it { is_expected.to include(pure_ids: []) }
    end

    context 'when the publications has imports from Pure' do
      before do
        create :publication_import, source: 'Pure', publication: publication, source_identifier: 'pure_abc123'
        create :publication_import, source: 'Pure', publication: publication, source_identifier: 'pure_def456'
      end

      it { is_expected.to include(pure_ids: ['pure_abc123', 'pure_def456']) }
    end

    context 'when the publication does not have imports from Activity Insight' do
      it { is_expected.to include(activity_insight_ids: []) }
    end

    context 'when the publications has imports from Activity Insight' do
      before do
        create :publication_import, source: 'Activity Insight', publication: publication, source_identifier: 'ai_abc123'
        create :publication_import, source: 'Activity Insight', publication: publication, source_identifier: 'ai_def456'
      end

      it { is_expected.to include(activity_insight_ids: ['ai_abc123', 'ai_def456']) }
    end

    context 'when the publication does not have tags' do
      it { is_expected.to include(tags: []) }
    end

    context 'when the publication has tags' do
      subject { serialized_data_attributes(publication) }

      let(:tag1) { create :tag, name: 'Thing 1' }
      let(:tag2) { create :tag, name: 'Thing 2' }

      before do
        create :publication_tagging, publication: publication, tag: tag1, rank: 1
        create :publication_tagging, publication: publication, tag: tag2, rank: 100
      end

      it { expect(subject).to include(tags: [{ name: 'Thing 2', rank: 100 },
                                             { name: 'Thing 1', rank: 1 }]) }
    end

    context 'when the publication does not have authorships' do
      it { is_expected.to include(profile_preferences: []) }
    end

    context 'when the publication has authorships' do
      let(:u1) { create :user, webaccess_id: 'abc123' }
      let(:u2) { create :user, webaccess_id: 'def456' }
      let(:u3) { create :user }

      before do
        create :authorship,
               publication: publication,
               user: u1,
               visible_in_profile: true,
               position_in_profile: 4,
               confirmed: true

        create :authorship,
               publication: publication,
               user: u2,
               visible_in_profile: false,
               position_in_profile: nil,
               confirmed: true

        create :authorship,
               publication: publication,
               user: u3,
               confirmed: false
      end

      it 'includes profile preferences' do
        expect(serialized_data_attributes(publication)[:profile_preferences]).to match_array(
          [{ user_id: u1.id,
             webaccess_id: 'abc123',
             visible_in_profile: true,
             position_in_profile: 4 },
           { user_id: u2.id,
             webaccess_id: 'def456',
             visible_in_profile: false,
             position_in_profile: nil }]
        )
      end
    end
  end
end
