# frozen_string_literal: true

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

  describe 'data attributes' do
    subject { serialized_data_attributes(presentation) }

    it { is_expected.to include(title: 'A Presentation') }
    it { is_expected.to include(activity_insight_identifier: '123456789') }
    it { is_expected.to include(name: 'A Name') }
    it { is_expected.to include(organization: 'An Organization') }
    it { is_expected.to include(location: 'A Location') }
    it { is_expected.to include(started_on: Date.new(2018, 12, 4)) }
    it { is_expected.to include(ended_on: Date.new(2018, 12, 5)) }
    it { is_expected.to include(presentation_type: 'The Presentation Type') }
    it { is_expected.to include(classification: 'The Classification') }
    it { is_expected.to include(meet_type: 'The Meet Type') }
    it { is_expected.to include(attendance: 100) }
    it { is_expected.to include(refereed: 'No') }
    it { is_expected.to include(abstract: 'An Abstract') }
    it { is_expected.to include(comment: 'A Comment') }
    it { is_expected.to include(scope: 'Local') }

    context 'when the presentation does not have contributions' do
      it { is_expected.to include(profile_preferences: []) }
    end

    context 'when the presentation has contributions' do
      let(:u1) { create :user, webaccess_id: 'abc123' }
      let(:u2) { create :user, webaccess_id: 'def456' }

      before do
        create :presentation_contribution,
               presentation: presentation,
               user: u1,
               visible_in_profile: true,
               position_in_profile: 4

        create :presentation_contribution,
               presentation: presentation,
               user: u2,
               visible_in_profile: false,
               position_in_profile: nil
      end

      it { expect(subject).to include(profile_preferences: [{ user_id: u1.id,
                                                              webaccess_id: 'abc123',
                                                              visible_in_profile: true,
                                                              position_in_profile: 4 },
                                                            { user_id: u2.id,
                                                              webaccess_id: 'def456',
                                                              visible_in_profile: false,
                                                              position_in_profile: nil }]) }
    end
  end
end
