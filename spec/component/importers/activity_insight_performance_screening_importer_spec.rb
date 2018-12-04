require 'component/component_spec_helper'

describe ActivityInsightPerformanceScreeningImporter do
  let(:importer) { ActivityInsightPerformanceScreeningImporter.new(filename: filename) }

  before(:each) do
    Performance.create( title: "Title 1", activity_insight_id: 161819957248 )
    Performance.create( title: "Title 2", activity_insight_id: 161395374080 )
    Performance.create( title: "Title 3", activity_insight_id: 160440864768 )
    Performance.create( title: "Title 4", activity_insight_id: 151334516736 )
  end


  describe '#call' do
    context "when given a well-formed .csv file of valid performance screening data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performance_screenings.csv') }

      it "creates a new performance_screening record for every valid row in the .csv file" do
        expect { importer.call }.to change { PerformanceScreening.count }.by 5

        performance1 = Performance.find_by( activity_insight_id: 161819957248 )

        p1 = PerformanceScreening.first
        p2 = PerformanceScreening.second
        p3 = PerformanceScreening.third
        p4 = PerformanceScreening.fourth
        p5 = PerformanceScreening.fifth

        expect(p1.screening_type).to eq 'Open Exhibit'
        expect(p1.name).to eq 'Center For Media Innovation / Point Park University'
        expect(p1.location).to eq nil

        expect(p2.screening_type).to eq 'Open Exhibit'
        expect(p2.name).to eq 'Palmer Museum of Art'
        expect(p2.location).to eq nil

        expect(p3.screening_type).to eq nil
        expect(p3.name).to eq nil
        expect(p3.location).to eq nil

        expect(p4.screening_type).to eq 'Invited'
        expect(p4.name).to eq 'International Communcation Association'
        expect(p4.location).to eq 'Prague, Czech Republic'

        expect(p5.screening_type).to eq 'Juried'
        expect(p5.name).to eq 'Collegetown Film Festival'
        expect(p5.location).to eq 'Athen, OH'

        expect(performance1.performance_screenings.count).to eq 2
        expect(performance1.performance_screenings.first.name).to eq 'Center For Media Innovation / Point Park University'
      end
    end
  end
end

