require 'component/component_spec_helper'

describe API::V1::PublicationSerializer do
  let(:publication) { create :publication,
                             title: 'publication 1',
                             secondary_title: 'pub 1 subtitle',
                             journal_title: 'prestegious journal',
                             publication_type: 'Journal Article',
                             publisher: 'a publisher',
                             status: 'published',
                             volume: '1',
                             issue: '2',
                             edition: '3',
                             page_range: '4-5',
                             authors_et_al: true,
                             published_on: date,
                             abstract: 'an abstract',
                             citation_count: 1000 }
  let(:date) { nil }

  describe "data attributes" do
    subject { serialized_data_attributes(publication) }
    it { is_expected.to include(:title => 'publication 1') }
    it { is_expected.to include(:secondary_title => 'pub 1 subtitle') }
    it { is_expected.to include(:journal_title => 'prestegious journal') }
    it { is_expected.to include(:publication_type => 'Journal Article') }
    it { is_expected.to include(:publisher => 'a publisher') }
    it { is_expected.to include(:status => 'published') }
    it { is_expected.to include(:volume => '1') }
    it { is_expected.to include(:issue => '2') }
    it { is_expected.to include(:edition => '3') }
    it { is_expected.to include(:page_range => '4-5') }
    it { is_expected.to include(:authors_et_al => true) }
    it { is_expected.to include(:abstract => 'an abstract') }
    it { is_expected.to include(:citation_count => 1000) }

    context "when the publication has a published_on date" do
      let(:date) { Date.new(2018, 8, 3) }
      it { is_expected.to include(:published_on => '2018-08-03') }
    end

    context "when the publication does not have a published_on date" do
      it { is_expected.to include(:published_on => nil) }
    end

    context "when the publication does not have contributors" do
      it { is_expected.to include(:contributors => []) }
    end

    context "when the publication has contributors" do
      before do
        create :contributor, first_name: 'a', middle_name: 'b', last_name: 'c', position: 2, publication: publication
        create :contributor, first_name: 'd', middle_name: 'e', last_name: 'f', position: 1, publication: publication
        create :contributor, first_name: 'g', middle_name: 'h', last_name: 'i', position: 3, publication: publication
      end

      subject { serialized_data_attributes(publication) }

      it { is_expected.to include(:contributors => [{first_name: 'd', middle_name: 'e', last_name: 'f'},
                                                    {first_name: 'a', middle_name: 'b', last_name: 'c'},
                                                    {first_name: 'g', middle_name: 'h', last_name: 'i'}]) }
    end

    context "when the publication does not have imports from Pure" do
      it { is_expected.to include(:pure_ids => []) }
    end

    context "when the publications has imports from Pure" do
      before do
        create :publication_import, source: 'Pure', publication: publication, source_identifier: 'pure_abc123'
        create :publication_import, source: 'Pure', publication: publication, source_identifier: 'pure_def456'
      end

      it { is_expected.to include(:pure_ids => ['pure_abc123', 'pure_def456']) }
    end

    context "when the publication does not have imports from Activity Insight" do
      it { is_expected.to include(:activity_insight_ids => []) }
    end

    context "when the publications has imports from Activity Insight" do
      before do
        create :publication_import, source: 'Activity Insight', publication: publication, source_identifier: 'ai_abc123'
        create :publication_import, source: 'Activity Insight', publication: publication, source_identifier: 'ai_def456'
      end

      it { is_expected.to include(:activity_insight_ids => ['ai_abc123', 'ai_def456']) }
    end

    context "when the publication does not have tags" do
      it { is_expected.to include(:tags => []) }
    end

    context "when the publication has tags" do
      let(:tag1) { create :tag, name: 'Thing 1' }
      let(:tag2) { create :tag, name: 'Thing 2' }
      before do
        create :publication_tagging, publication: publication, tag: tag1, rank: 1
        create :publication_tagging, publication: publication, tag: tag2, rank: 100
      end

      subject { serialized_data_attributes(publication) }

      it { is_expected.to include(:tags => [{name: 'Thing 2', rank: 100},
                                            {name: 'Thing 1', rank: 1}] ) }
    end
  end
end
