require 'component/component_spec_helper'

describe ActivityInsightPerformanceImporter do
  let(:importer) { ActivityInsightPerformanceImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid performance data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performances.csv') }

      it "creates a new performance record for every valid row in the .csv file" do
        expect { importer.call }.to change { Performance.count }.by 5

        p1 = Performance.find_by(activity_insight_id: '16682733568')
        p2 = Performance.find_by(activity_insight_id: '127076831232')
        p3 = Performance.find_by(activity_insight_id: '126500763648')
        p4 = Performance.find_by(activity_insight_id: '157267075072')
        p5 = Performance.find_by(activity_insight_id: '157267075073')

        expect(p1.title).to eq 'Test Performance 1'
        expect(p1.performance_type).to eq 'theatre'
        expect(p1.sponsor).to eq nil
        expect(p1.description).to eq 'This is also a performance.'
        expect(p1.group_name).to eq nil
        expect(p1.location).to eq 'State College, PA'
        expect(p1.delivery_type).to eq nil
        expect(p1.scope).to eq nil
        expect(p1.start_on).to eq Date.new(2007, 1, 15)
        expect(p1.end_on).to eq Date.new(2008, 4, 12)
        expect(p1.visible).to eq true

        expect(p2.title).to eq 'Test Performance 2'
        expect(p2.performance_type).to eq 'Poetry/Fiction'
        expect(p2.sponsor).to eq 'Sponsor 3'
        expect(p2.description).to eq 'This is a performance.'
        expect(p2.group_name).to eq nil
        expect(p2.location).to eq 'Hershey, PA'
        expect(p2.delivery_type).to eq 'Competition'
        expect(p2.scope).to eq 'Local'
        expect(p2.start_on).to eq Date.new(2016, 4, 01)
        expect(p2.end_on).to eq Date.new(2016, 4, 30)
        expect(p2.visible).to eq true

        expect(p3.title).to eq 'Test Performance 3'
        expect(p3.performance_type).to eq 'Film - Documentary'
        expect(p3.sponsor).to eq 'Sponsor 1'
        expect(p3.description).to eq nil
        expect(p3.group_name).to eq 'Penn State Performance Group'
        expect(p3.location).to eq 'New Kensington, PA'
        expect(p3.delivery_type).to eq 'Invitation'
        expect(p3.scope).to eq 'Regional'
        expect(p3.start_on).to eq Date.new(2009, 2, 01)
        expect(p3.end_on).to eq Date.new(2009, 8, 31)
        expect(p3.visible).to eq true

        expect(p4.title).to eq 'Test Performance 4'
        expect(p4.performance_type).to eq 'Print Edition for Something'
        expect(p4.sponsor).to eq 'Sponsor 2'
        expect(p4.description).to eq nil
        expect(p4.group_name).to eq nil
        expect(p4.location).to eq nil
        expect(p4.delivery_type).to eq nil
        expect(p4.scope).to eq nil
        expect(p4.start_on).to eq Date.new(2015, 5, 06)
        expect(p4.end_on).to eq Date.new(2015, 12, 01)
        expect(p4.visible).to eq true

        expect(p5.title).to eq 'Test Performance 5'
        expect(p5.performance_type).to eq 'Print Edition for Something'
        expect(p5.sponsor).to eq 'Sponsor 2'
        expect(p5.description).to eq nil
        expect(p5.group_name).to eq nil
        expect(p5.location).to eq nil
        expect(p5.delivery_type).to eq nil
        expect(p5.scope).to eq nil
        expect(p5.start_on).to eq Date.new(2016, 5, 06)
        expect(p5.end_on).to eq Date.new(2016, 12, 01)
        expect(p5.visible).to eq true

      end

      context "when a performance record already exists for one of the rows in the .csv" do
        let(:existing_pub) { create title: 'Test Performance 1',
                                    performance_type: 'theatre',
                                    sponsor: nil,
                                    description: 'Different description.',
                                    group_name: nil,
                                    location: 'State College, PA',
                                    delivery_type: nil,
                                    scope: nil,
                                    start_on: Date.new(2007, 1, 15),
                                    end_on: Date.new(2008, 4, 12),
                                    activity_insight_id: 16682733568 }

        it "updates that performance record" do
          importer.call
          
          p1 = Performance.find_by(activity_insight_id: '16682733568')

          expect(p1.description).to eq 'This is also a performance.'
        end
      end
    end
  end
end
