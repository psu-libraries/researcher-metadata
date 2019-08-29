require 'component/component_spec_helper'

describe ActivityInsightPresentationImporter do
  let(:importer) { ActivityInsightPresentationImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid presentation data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_presentations.csv') }

      context "when no presentation records exist in the database" do
        it "creates a new presentation record for every row in the .csv file" do
          expect { importer.call }.to change { Presentation.count }.by 3

          p1 = Presentation.find_by(activity_insight_identifier: '113168144384')
          p2 = Presentation.find_by(activity_insight_identifier: '107659857920')
          p3 = Presentation.find_by(activity_insight_identifier: '169406947328')

          expect(p1.title).to eq 'Test Title One'
          expect(p1.name).to eq 'Test Name One'
          expect(p1.organization).to eq 'Test Org One'
          expect(p1.location).to eq 'Philadelphia, PA'
          expect(p1.started_on).to eq Date.new(2015, 8, 10)
          expect(p1.ended_on).to eq Date.new(2015, 8, 11)
          expect(p1.presentation_type).to eq 'Presentations'
          expect(p1.classification).to eq 'Basic or Discovery Scholarship'
          expect(p1.meet_type).to eq 'Academic'
          expect(p1.attendance).to eq 20
          expect(p1.refereed).to eq 'No'
          expect(p1.abstract).to eq 'Test Abstract One'
          expect(p1.comment).to eq 'Test Comment One'
          expect(p1.scope).to eq 'Local'
          expect(p1.visible).to eq true
          expect(p1.updated_by_user_at).to be_nil

          expect(p2.title).to eq 'Test Title Two'
          expect(p2.name).to eq 'Test Name Two'
          expect(p2.organization).to eq 'Test Org Two'
          expect(p2.location).to eq 'Ft. Myers, FL'
          expect(p2.started_on).to eq Date.new(2015, 4, 15)
          expect(p2.ended_on).to eq Date.new(2015, 4, 15)
          expect(p2.presentation_type).to eq 'Presentations'
          expect(p2.classification).to eq 'Teaching and Learning Scholarship'
          expect(p2.meet_type).to eq 'Academic'
          expect(p2.attendance).to eq nil
          expect(p2.refereed).to eq 'No'
          expect(p2.abstract).to eq 'Test Abstract Two'
          expect(p2.comment).to eq 'Test Comment Two'
          expect(p2.scope).to eq nil
          expect(p2.visible).to eq true
          expect(p2.updated_by_user_at).to eq nil

          expect(p3.title).to eq 'Test Title Three'
          expect(p3.name).to eq 'Test Name Three'
          expect(p3.organization).to eq 'Test Org Three'
          expect(p3.location).to eq 'Denver, CO'
          expect(p3.started_on).to eq nil
          expect(p3.ended_on).to eq nil
          expect(p3.presentation_type).to eq 'Some Other Type'
          expect(p3.classification).to eq nil
          expect(p3.meet_type).to eq 'Academic'
          expect(p3.attendance).to eq nil
          expect(p3.refereed).to eq 'No'
          expect(p3.abstract).to eq nil
          expect(p3.comment).to eq nil
          expect(p3.scope).to eq 'National'
          expect(p3.visible).to eq true
          expect(p3.updated_by_user_at).to eq nil
        end
      end

      context "when a presentation in the .csv file already exists in the database" do
        let!(:existing_pres) { create :presentation,
                                      activity_insight_identifier: '107659857920',
                                      title: 'Existing Title',
                                      name: 'Existing Name',
                                      organization: 'Existing Org',
                                      location: 'Existing Loc',
                                      started_on: Date.new(1970, 1, 1),
                                      ended_on: Date.new(1970, 1, 2),
                                      presentation_type: 'Existing Type',
                                      classification: 'Existing Class',
                                      meet_type: 'Existing Meet',
                                      attendance: 100,
                                      refereed: 'Yes',
                                      abstract: 'Existing Abstract',
                                      comment: 'Existing Comment',
                                      scope: 'Existing Scope',
                                      visible: false,
                                      updated_by_user_at: timestamp}

        context "when the existing presentation has been updated by a human" do
          let(:timestamp) { Time.new(2018, 10, 10, 0, 0, 0) }

          it "creates new records for the new presentations and does not update the existing presentation" do
            expect { importer.call }.to change { Presentation.count }.by 2

            p1 = Presentation.find_by(activity_insight_identifier: '113168144384')
            p2 = Presentation.find_by(activity_insight_identifier: '107659857920')
            p3 = Presentation.find_by(activity_insight_identifier: '169406947328')

            expect(p1.title).to eq 'Test Title One'
            expect(p1.name).to eq 'Test Name One'
            expect(p1.organization).to eq 'Test Org One'
            expect(p1.location).to eq 'Philadelphia, PA'
            expect(p1.started_on).to eq Date.new(2015, 8, 10)
            expect(p1.ended_on).to eq Date.new(2015, 8, 11)
            expect(p1.presentation_type).to eq 'Presentations'
            expect(p1.classification).to eq 'Basic or Discovery Scholarship'
            expect(p1.meet_type).to eq 'Academic'
            expect(p1.attendance).to eq 20
            expect(p1.refereed).to eq 'No'
            expect(p1.abstract).to eq 'Test Abstract One'
            expect(p1.comment).to eq 'Test Comment One'
            expect(p1.scope).to eq 'Local'
            expect(p1.visible).to eq true
            expect(p1.updated_by_user_at).to be_nil

            expect(p2.title).to eq 'Existing Title'
            expect(p2.name).to eq 'Existing Name'
            expect(p2.organization).to eq 'Existing Org'
            expect(p2.location).to eq 'Existing Loc'
            expect(p2.started_on).to eq Date.new(1970, 1, 1)
            expect(p2.ended_on).to eq Date.new(1970, 1, 2)
            expect(p2.presentation_type).to eq 'Existing Type'
            expect(p2.classification).to eq 'Existing Class'
            expect(p2.meet_type).to eq 'Existing Meet'
            expect(p2.attendance).to eq 100
            expect(p2.refereed).to eq 'Yes'
            expect(p2.abstract).to eq 'Existing Abstract'
            expect(p2.comment).to eq 'Existing Comment'
            expect(p2.scope).to eq 'Existing Scope'
            expect(p2.visible).to eq false
            expect(p2.updated_by_user_at).to eq Time.new(2018, 10, 10, 0, 0, 0)

            expect(p3.title).to eq 'Test Title Three'
            expect(p3.name).to eq 'Test Name Three'
            expect(p3.organization).to eq 'Test Org Three'
            expect(p3.location).to eq 'Denver, CO'
            expect(p3.started_on).to eq nil
            expect(p3.ended_on).to eq nil
            expect(p3.presentation_type).to eq 'Some Other Type'
            expect(p3.classification).to eq nil
            expect(p3.meet_type).to eq 'Academic'
            expect(p3.attendance).to eq nil
            expect(p3.refereed).to eq 'No'
            expect(p3.abstract).to eq nil
            expect(p3.comment).to eq nil
            expect(p3.scope).to eq 'National'
            expect(p3.visible).to eq true
            expect(p3.updated_by_user_at).to eq nil
          end
        end

        context "when the existing presentation has not been updated by a human" do
          let(:timestamp) { nil }

          it "creates new records for the new presentations and updates the existing presentation" do
            expect { importer.call }.to change { Presentation.count }.by 2

            p1 = Presentation.find_by(activity_insight_identifier: '113168144384')
            p2 = Presentation.find_by(activity_insight_identifier: '107659857920')
            p3 = Presentation.find_by(activity_insight_identifier: '169406947328')

            expect(p1.title).to eq 'Test Title One'
            expect(p1.name).to eq 'Test Name One'
            expect(p1.organization).to eq 'Test Org One'
            expect(p1.location).to eq 'Philadelphia, PA'
            expect(p1.started_on).to eq Date.new(2015, 8, 10)
            expect(p1.ended_on).to eq Date.new(2015, 8, 11)
            expect(p1.presentation_type).to eq 'Presentations'
            expect(p1.classification).to eq 'Basic or Discovery Scholarship'
            expect(p1.meet_type).to eq 'Academic'
            expect(p1.attendance).to eq 20
            expect(p1.refereed).to eq 'No'
            expect(p1.abstract).to eq 'Test Abstract One'
            expect(p1.comment).to eq 'Test Comment One'
            expect(p1.scope).to eq 'Local'
            expect(p1.visible).to eq true
            expect(p1.updated_by_user_at).to be_nil

            expect(p2.title).to eq 'Test Title Two'
            expect(p2.name).to eq 'Test Name Two'
            expect(p2.organization).to eq 'Test Org Two'
            expect(p2.location).to eq 'Ft. Myers, FL'
            expect(p2.started_on).to eq Date.new(2015, 4, 15)
            expect(p2.ended_on).to eq Date.new(2015, 4, 15)
            expect(p2.presentation_type).to eq 'Presentations'
            expect(p2.classification).to eq 'Teaching and Learning Scholarship'
            expect(p2.meet_type).to eq 'Academic'
            expect(p2.attendance).to eq nil
            expect(p2.refereed).to eq 'No'
            expect(p2.abstract).to eq 'Test Abstract Two'
            expect(p2.comment).to eq 'Test Comment Two'
            expect(p2.scope).to eq nil
            expect(p2.visible).to eq false
            expect(p2.updated_by_user_at).to eq nil

            expect(p3.title).to eq 'Test Title Three'
            expect(p3.name).to eq 'Test Name Three'
            expect(p3.organization).to eq 'Test Org Three'
            expect(p3.location).to eq 'Denver, CO'
            expect(p3.started_on).to eq nil
            expect(p3.ended_on).to eq nil
            expect(p3.presentation_type).to eq 'Some Other Type'
            expect(p3.classification).to eq nil
            expect(p3.meet_type).to eq 'Academic'
            expect(p3.attendance).to eq nil
            expect(p3.refereed).to eq 'No'
            expect(p3.abstract).to eq nil
            expect(p3.comment).to eq nil
            expect(p3.scope).to eq 'National'
            expect(p3.visible).to eq true
            expect(p3.updated_by_user_at).to eq nil
          end
        end
      end
    end
  end
end
