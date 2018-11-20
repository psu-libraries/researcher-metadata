require 'component/component_spec_helper'
  
describe ActivityInsightPerformanceContributorsImporter do
  let(:importer) { ActivityInsightPerformanceContributorsImporter.new(filename: filename) }

  before(:each) do
    u1 = User.create( webaccess_id: "abc123",
                      activity_insight_identifier: 123456,
                      first_name: "Test",
                      last_name: "User1" )
    u2 = User.create( webaccess_id: "def345",
                      activity_insight_identifier: 654321,
                      first_name: "Test",
                      last_name: "User2" )
    u3 = User.create( webaccess_id: "ghi678",
                      activity_insight_identifier: 987654,
                      first_name: "Test",
                      last_name: "User3" )

    p1 = create(:performance, activity_insight_id: 166232324096)
    p2 = create(:performance, activity_insight_id: 166232252416)
    p3 = create(:performance, activity_insight_id: 166232252419)

    UserPerformance.create(user: u3, performance: p1)
    UserPerformance.create(user: u3, performance: p2)
    UserPerformance.create(user: u3, performance: p3)
  end

  describe '#call' do
    context "when given a well-formed .csv file of valid performance contributers data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performance_contributors.csv') }

      it "creates a new UserPerformance record for every valid row in the .csv file" do
        expect { importer.call }.to change { UserPerformance.count }.by 2
      end
    end
  end
end


