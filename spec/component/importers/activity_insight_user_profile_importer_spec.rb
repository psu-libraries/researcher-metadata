require 'component/component_spec_helper'

describe ActivityInsightUserProfileImporter do
  let(:importer) { ActivityInsightUserProfileImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid user profile data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_user_profiles.csv') }

      context "when no user records exist in the database" do
        it "does not create any new records" do
          expect { importer.call }.not_to change { User.count }
        end
      end

      context "when a user in the .csv file already exists in the database" do
        let!(:existing_user) { create :user,
                                      webaccess_id: 'bbt2',
                                      ai_teaching_interests: 'existing teaching interests',
                                      ai_research_interests: 'existing research interests',
                                      updated_by_user_at: timestamp }

        context "when the existing user has been updated by a human" do
          let(:timestamp) { Time.zone.now }
          it "does not update the existing user" do
            importer.call

            u = User.find_by(webaccess_id: 'bbt2')

            expect(u.ai_teaching_interests).to eq 'existing teaching interests'
            expect(u.ai_research_interests).to eq 'existing research interests'
          end
        end
        context "when the existing user has not been updated by a human" do
          let(:timestamp) { nil }
          it "updates the existing user" do
            importer.call

            u = User.find_by(webaccess_id: 'bbt2')

            expect(u.ai_teaching_interests).to eq 'My teaching interests'
            expect(u.ai_research_interests).to eq 'My research interests'
          end
        end
      end
    end
  end
end