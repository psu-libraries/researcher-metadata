# frozen_string_literal: true

require 'component/component_spec_helper'

describe API::V1::PerformanceSerializer do
  let(:performance) { create :performance,
                             title: 'Performance 1',
                             activity_insight_id: 123456789,
                             performance_type: 'Other',
                             sponsor: 'A Sponsor',
                             description: 'A description',
                             group_name: 'A Group',
                             location: 'State College, PA',
                             delivery_type: 'Competition',
                             scope: 'Local',
                             start_on: Date.new(2018, 12, 4),
                             end_on: Date.new(2018, 12, 5) }

  describe 'data attributes' do
    subject { serialized_data_attributes(performance) }

    it { is_expected.to include(title: 'Performance 1') }
    it { is_expected.to include(activity_insight_id: 123456789) }
    it { is_expected.to include(performance_type: 'Other') }
    it { is_expected.to include(sponsor: 'A Sponsor') }
    it { is_expected.to include(description: 'A description') }
    it { is_expected.to include(group_name: 'A Group') }
    it { is_expected.to include(location: 'State College, PA') }
    it { is_expected.to include(delivery_type: 'Competition') }
    it { is_expected.to include(scope: 'Local') }
    it { is_expected.to include(start_on: Date.new(2018, 12, 4)) }
    it { is_expected.to include(end_on: Date.new(2018, 12, 5)) }

    context 'when the performance does not have screenings' do
      it { is_expected.to include(performance_screenings: []) }
    end

    context 'when the performance has screenings' do
      subject { serialized_data_attributes(performance) }

      before do
        create :performance_screening, name: 'Screening 1', screening_type: 'Movie', location: 'Town', performance: performance
        create :performance_screening, name: 'Screening 2', screening_type: 'Invited', location: 'City', performance: performance
      end

      it { expect(subject).to include(performance_screenings: [{ name: 'Screening 1', screening_type: 'Movie', location: 'Town' },
                                                               { name: 'Screening 2', screening_type: 'Invited', location: 'City' }]) }
    end

    context 'when the performance does not have user_performances' do
      it { is_expected.to include(profile_preferences: []) }
      it { is_expected.to include(user_performances: []) }
    end

    context 'when the performance has user_performances' do
      let(:u1) { create :user,
                        webaccess_id: 'abc123',
                        first_name: 'Test',
                        last_name: 'User' }
      let(:u2) { create :user,
                        webaccess_id: 'def456',
                        first_name: 'Another',
                        last_name: 'User' }

      before do
        create :user_performance,
               performance: performance,
               user: u1,
               visible_in_profile: true,
               position_in_profile: 4,
               contribution: 'Performer',
               student_level: 'Graduate',
               role_other: nil

        create :user_performance,
               performance: performance,
               user: u2,
               visible_in_profile: false,
               position_in_profile: nil,
               contribution: nil,
               student_level: nil,
               role_other: nil
      end

      it { expect(subject).to include(profile_preferences: [{ user_id: u1.id,
                                                              webaccess_id: 'abc123',
                                                              visible_in_profile: true,
                                                              position_in_profile: 4 },
                                                            { user_id: u2.id,
                                                              webaccess_id: 'def456',
                                                              visible_in_profile: false,
                                                              position_in_profile: nil }]) }

      it { expect(subject).to include(user_performances: [{ first_name: 'Test',
                                                            last_name: 'User',
                                                            contribution: 'Performer',
                                                            student_level: 'Graduate',
                                                            role_other: nil },
                                                          { first_name: 'Another',
                                                            last_name: 'User',
                                                            contribution: nil,
                                                            student_level: nil,
                                                            role_other: nil }]) }
    end
  end
end
