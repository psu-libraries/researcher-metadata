require 'component/component_spec_helper'

describe ActivityInsightEducationHistoryImporter do
  let(:importer) { ActivityInsightEducationHistoryImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid education history data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_education_history.csv') }

      let!(:user1) { create :user, webaccess_id: 'def456' }
      let!(:user2) { create :user, webaccess_id: 'ghi789' }

      context "when no education history records exist in the database" do
        it "creates a new education history record for every row in the .csv file that has a corresponding user" do
          expect { importer.call }.to change { EducationHistoryItem.count }.by 2

          i1 = EducationHistoryItem.find_by(activity_insight_identifier: '160732039168')
          i2 = EducationHistoryItem.find_by(activity_insight_identifier: '103858878464')

          expect(i1.user).to eq user1
          expect(i1.degree).to eq 'AB'
          expect(i1.explanation_of_other_degree).to be_nil
          expect(i1.is_honorary_degree).to eq 'No'
          expect(i1.is_highest_degree_earned).to eq 'No'
          expect(i1.institution).to eq 'Cornell University'
          expect(i1.school).to eq 'Arts and Sciences'
          expect(i1.location_of_institution).to eq 'Ithaca, NY'
          expect(i1.emphasis_or_major).to eq 'Physics'
          expect(i1.supporting_areas_of_emphasis).to be_nil
          expect(i1.dissertation_or_thesis_title).to eq 'My Test Thesis'
          expect(i1.honor_or_distinction).to be_nil
          expect(i1.description).to eq 'Test description'
          expect(i1.comments).to be_nil
          expect(i1.start_year).to eq 1985
          expect(i1.end_year).to eq 1989

          expect(i2.user).to eq user2
          expect(i2.degree).to eq 'Other'
          expect(i2.explanation_of_other_degree).to eq 'Other degree'
          expect(i2.is_honorary_degree).to be_nil
          expect(i2.is_highest_degree_earned).to eq 'No'
          expect(i2.institution).to eq 'Kenyon College'
          expect(i2.school).to be_nil
          expect(i2.location_of_institution).to eq 'Gambier, Ohio'
          expect(i2.emphasis_or_major).to eq 'Physics'
          expect(i2.supporting_areas_of_emphasis).to eq 'Chemistry'
          expect(i2.dissertation_or_thesis_title).to be_nil
          expect(i2.honor_or_distinction).to eq 'Magna cum laude'
          expect(i2.description).to be_nil
          expect(i2.comments).to eq 'Test comments'
          expect(i2.start_year).to eq 1970
          expect(i2.end_year).to eq 1974
        end
      end

      context "when an education history item in the .csv file already exists in the database" do
        let!(:existing_item) { create :education_history_item,
                                      activity_insight_identifier: '160732039168',
                                      user: user1,
                                      degree: 'Existing degree',
                                      explanation_of_other_degree: 'Existing explanation',
                                      is_honorary_degree: 'Yes',
                                      is_highest_degree_earned: 'Yes',
                                      institution: 'Existing institution',
                                      school: 'Existing school',
                                      location_of_institution: 'Existing location',
                                      emphasis_or_major: 'Existing Major',
                                      supporting_areas_of_emphasis: 'Existing areas',
                                      dissertation_or_thesis_title: 'Existing title',
                                      honor_or_distinction: 'Existing honor',
                                      description: 'Existing description',
                                      comments: 'Existing comments',
                                      start_year: 1900,
                                      end_year: 1910 }


        it "creates new records for the new items and updates the existing item" do
          expect { importer.call }.to change { EducationHistoryItem.count }.by 1

          i1 = EducationHistoryItem.find_by(activity_insight_identifier: '160732039168')
          i2 = EducationHistoryItem.find_by(activity_insight_identifier: '103858878464')

          expect(i1.user).to eq user1
          expect(i1.degree).to eq 'AB'
          expect(i1.explanation_of_other_degree).to be_nil
          expect(i1.is_honorary_degree).to eq 'No'
          expect(i1.is_highest_degree_earned).to eq 'No'
          expect(i1.institution).to eq 'Cornell University'
          expect(i1.school).to eq 'Arts and Sciences'
          expect(i1.location_of_institution).to eq 'Ithaca, NY'
          expect(i1.emphasis_or_major).to eq 'Physics'
          expect(i1.supporting_areas_of_emphasis).to be_nil
          expect(i1.dissertation_or_thesis_title).to eq 'My Test Thesis'
          expect(i1.honor_or_distinction).to be_nil
          expect(i1.description).to eq 'Test description'
          expect(i1.comments).to be_nil
          expect(i1.start_year).to eq 1985
          expect(i1.end_year).to eq 1989

          expect(i2.user).to eq user2
          expect(i2.degree).to eq 'Other'
          expect(i2.explanation_of_other_degree).to eq 'Other degree'
          expect(i2.is_honorary_degree).to be_nil
          expect(i2.is_highest_degree_earned).to eq 'No'
          expect(i2.institution).to eq 'Kenyon College'
          expect(i2.school).to be_nil
          expect(i2.location_of_institution).to eq 'Gambier, Ohio'
          expect(i2.emphasis_or_major).to eq 'Physics'
          expect(i2.supporting_areas_of_emphasis).to eq 'Chemistry'
          expect(i2.dissertation_or_thesis_title).to be_nil
          expect(i2.honor_or_distinction).to eq 'Magna cum laude'
          expect(i2.description).to be_nil
          expect(i2.comments).to eq 'Test comments'
          expect(i2.start_year).to eq 1970
          expect(i2.end_year).to eq 1974
        end
      end
    end
  end
end
