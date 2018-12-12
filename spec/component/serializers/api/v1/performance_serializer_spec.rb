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

  let(:user) { create :user,
                      first_name: 'Test',
                      last_name: 'User' }

  before do
    create :user_performance,
            user: user,
            performance: performance,
            contribution: 'Performer',
            student_level: 'Graduate',
            role_other: nil
  end
  
  describe "data attributes" do
    subject { serialized_data_attributes(performance) }

    it { is_expected.to include(:title => 'Performance 1') }
    it { is_expected.to include(:activity_insight_id => 123456789) }
    it { is_expected.to include(:performance_type => 'Other') }
    it { is_expected.to include(:sponsor => 'A Sponsor') }
    it { is_expected.to include(:description => 'A description') }
    it { is_expected.to include(:group_name => 'A Group') }
    it { is_expected.to include(:location => 'State College, PA') }
    it { is_expected.to include(:delivery_type => 'Competition') }
    it { is_expected.to include(:scope => 'Local') }
    it { is_expected.to include(:start_on => Date.new(2018, 12, 4)) }
    it { is_expected.to include(:end_on => Date.new(2018, 12, 5)) }

    it { is_expected.to include(:user_performances => [{first_name: 'Test', last_name: 'User', 
                                                        contribution: 'Performer', student_level: 'Graduate', role_other: nil}]) }

    context "when the performance does not have screenings" do
      it { is_expected.to include(:performance_screenings => []) }
    end

    context "when the performance has screenings" do

      before do
        create :performance_screening, name: 'Screening 1', screening_type: 'Movie', location: 'Town', performance: performance
        create :performance_screening, name: 'Screening 2', screening_type: 'Invited', location: 'City', performance: performance
      end

      subject { serialized_data_attributes(performance) }

      it { is_expected.to include(:performance_screenings => [{name: 'Screening 1', screening_type: 'Movie', location: 'Town'},
                                                              {name: 'Screening 2', screening_type: 'Invited', location: 'City'}] ) }
    end
  end
end

  
