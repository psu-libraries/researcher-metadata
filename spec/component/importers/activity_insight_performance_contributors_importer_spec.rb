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
    p3 = create(:performance, activity_insight_id: 16682733568)
    p4 = create(:performance, activity_insight_id: 166232252419)
  end

  describe '#call' do
    context "when given a .csv file of performance contributors data that contains a 'role_other' column" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performance_contributors1.csv') }

      it "creates a new UserPerformance record for every valid row in the .csv file" do
        expect { importer.call }.to change { UserPerformance.count }.by 3

        expect(User.find_by(webaccess_id: "ghi678").user_performances.last.role_other).to eq('MC')
        expect(User.find_by(webaccess_id: "ghi678").user_performances.last.contribution).to eq('Producer')
        expect(User.find_by(webaccess_id: "ghi678").user_performances.last.student_level).to eq(nil)
        expect(User.find_by(webaccess_id: "ghi678").user_performances.last.activity_insight_id).to eq(166232252420)
        expect(User.find_by(webaccess_id: "ghi678").user_performances.last.performance).to be_truthy

        expect(User.find_by(webaccess_id: "abc123").user_performances.last.role_other).to eq(nil)
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.contribution).to eq('Director')
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.student_level).to eq(nil)
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.activity_insight_id).to eq(166232324097)
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.performance).to be_truthy

        expect(User.find_by(webaccess_id: "def345").user_performances.last.role_other).to eq(nil)
        expect(User.find_by(webaccess_id: "def345").user_performances.last.contribution).to eq('Producer')
        expect(User.find_by(webaccess_id: "def345").user_performances.last.student_level).to eq('Graduate')
        expect(User.find_by(webaccess_id: "def345").user_performances.last.activity_insight_id).to eq(166232252417)
        expect(User.find_by(webaccess_id: "def345").user_performances.last.performance).to be_truthy
      end
    end

    context "when a user_performance record exists with the same activity_insight_id" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performance_contributors1.csv') }
      let(:u4) { create :user }
      let(:p5) { create :performance }

      it "does not create a new record and updates that record" do
        UserPerformance.create(user: u4, performance: p5, activity_insight_id: 166232252420, contribution: 'Something')

        expect { importer.call }.to change { UserPerformance.count }.by 2
        expect(UserPerformance.find_by(activity_insight_id: 166232252420).contribution).to eq('Producer')
      end
    end

    context "when given a .csv file of performance contributors data not containing a 'role_other' column" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_performance_contributors2.csv') }

      it "creates a new UserPerformance record for every valid row in the .csv file" do
        expect { importer.call }.to change { UserPerformance.count }.by 1

        expect(User.find_by(webaccess_id: "abc123").user_performances.last.role_other).to eq(nil)
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.contribution).to eq('Producer')
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.student_level).to eq('Graduate')
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.activity_insight_id).to eq(16682733569)
        expect(User.find_by(webaccess_id: "abc123").user_performances.last.performance).to be_truthy
      end
    end
  end
end


