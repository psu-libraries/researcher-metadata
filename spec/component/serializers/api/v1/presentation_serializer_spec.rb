require 'component/component_spec_helper'

describe API::V1::PresentationSerializer do
  let(:presentation) { create :presentation,
                              title: 'A Presentation',
                              activity_insight_identifier: '123456789',
                              name: 'A Name',
                              organization: 'An Organization',
                              location: 'A Location',
                              started_on: Date.new(2018, 12, 4),
                              ended_on: Date.new(2018, 12, 5),
                              presentation_type: 'The Presentation Type',
                              classification: 'The Classification',
                              meet_type: 'The Meet Type',
                              attendance: 100,
                              refereed: 'No',
                              abstract: 'An Abstract',
                              comment: 'A Comment',
                              scope: 'Local' }


  describe "data attributes" do
    subject { serialized_data_attributes(presentation) }

    it { is_expected.to include(:title => 'A Presentation') }
    it { is_expected.to include(:activity_insight_identifier => '123456789') }
    it { is_expected.to include(:name => 'A Name') }
    it { is_expected.to include(:organization => 'An Organization') }
    it { is_expected.to include(:location => 'A Location') }
    it { is_expected.to include(:started_on => Date.new(2018, 12, 4)) }
    it { is_expected.to include(:ended_on => Date.new(2018, 12, 5)) }
    it { is_expected.to include(:presentation_type => 'The Presentation Type') }
    it { is_expected.to include(:classification => 'The Classification') }
    it { is_expected.to include(:meet_type => 'The Meet Type') }
    it { is_expected.to include(:attendance => 100) }
    it { is_expected.to include(:refereed => 'No') }
    it { is_expected.to include(:abstract => 'An Abstract') }
    it { is_expected.to include(:comment => 'A Comment') }
    it { is_expected.to include(:scope => 'Local') }
  end
end
