require 'component/component_spec_helper'

describe ActivityInsightAuthorshipImporter do
  let(:importer) { ActivityInsightAuthorshipImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid authorship data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_authorships.csv') }

      context "when no authorship records exist in the database" do
        context "when a user exists for every Penn State authorship in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }
          let!(:u2) { create :user, activity_insight_identifier: '1000001' }
          let!(:u3) { create :user, activity_insight_identifier: '1000002' }

          context "when a publication exists for every Penn State authorship in the .csv" do
            let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
            let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
            let!(:pi3) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

            it "creates a new record for every Penn State authorship in the .csv" do
              expect { importer.call }.to change { Authorship.count }.by 4

              a1 = Authorship.find_by(user: u1, publication: pi1.publication)
              a2 = Authorship.find_by(user: u1, publication: pi2.publication)
              a3 = Authorship.find_by(user: u2, publication: pi3.publication)
              a4 = Authorship.find_by(user: u3, publication: pi3.publication)

              expect(a1.author_number).to eq 1
              expect(a2.author_number).to eq 1
              expect(a3.author_number).to eq 1
              expect(a4.author_number).to eq 2
            end
          end

          context "when no publication exists for a Penn State authorship in the .csv" do
            let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
            let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

            it "creates a new record for every Penn State authorship in the .csv with a corresponding publication" do
              expect { importer.call }.to change { Authorship.count }.by 3

              a1 = Authorship.find_by(user: u1, publication: pi1.publication)
              a2 = Authorship.find_by(user: u2, publication: pi2.publication)
              a3 = Authorship.find_by(user: u3, publication: pi2.publication)

              expect(a1.author_number).to eq 1
              expect(a2.author_number).to eq 1
              expect(a3.author_number).to eq 2
            end
          end
        end

        context "when no user exists for a Penn State authorship in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }
          let!(:u2) { create :user, activity_insight_identifier: '1000002' }

          context "when a publication exists for every Penn State authorship in the .csv" do
            let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
            let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
            let!(:pi3) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

            it "creates a new record for every Penn State authorship in the .csv with a corresponding user" do
              expect { importer.call }.to change { Authorship.count }.by 3

              a1 = Authorship.find_by(user: u1, publication: pi1.publication)
              a2 = Authorship.find_by(user: u1, publication: pi2.publication)
              a3 = Authorship.find_by(user: u2, publication: pi3.publication)

              expect(a1.author_number).to eq 1
              expect(a2.author_number).to eq 1
              expect(a3.author_number).to eq 2
            end
          end

          context "when no publication exists for a Penn State authorship in the .csv" do
            let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
            let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

            it "creates a new record for every Penn State authorship in the .csv with a corresponding user and publication" do
              expect { importer.call }.to change { Authorship.count }.by 2

              a1 = Authorship.find_by(user: u1, publication: pi1.publication)
              a2 = Authorship.find_by(user: u2, publication: pi2.publication)

              expect(a1.author_number).to eq 1
              expect(a2.author_number).to eq 2
            end
          end
        end
      end

      context "when an authorship record already exists for a Penn State authorship in the .csv" do
        before { create :authorship, user: u1, publication: pi1.publication, author_number: 4 }

        context "when a user exists for every Penn State authorship in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }
          let!(:u2) { create :user, activity_insight_identifier: '1000001' }
          let!(:u3) { create :user, activity_insight_identifier: '1000002' }

          context "when a publication exists for every Penn State authorship in the .csv" do
            let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
            let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
            let!(:pi3) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

            context "when the existing authorship has been updated by a human" do
              before { pi1.publication.update_column(:updated_by_user_at, Time.current ) }

              it "creates a new record for every new Penn State authorship and does not update the existing authorship" do
                expect { importer.call }.to change { Authorship.count }.by 3

                a1 = Authorship.find_by(user: u1, publication: pi1.publication)
                a2 = Authorship.find_by(user: u1, publication: pi2.publication)
                a3 = Authorship.find_by(user: u2, publication: pi3.publication)
                a4 = Authorship.find_by(user: u3, publication: pi3.publication)

                expect(a1.author_number).to eq 4
                expect(a2.author_number).to eq 1
                expect(a3.author_number).to eq 1
                expect(a4.author_number).to eq 2
              end
            end

            context "when the existing authorship has not been updated by a human" do
              it "creates a new record for every new Penn State authorship and updates the existing authorship" do
                expect { importer.call }.to change { Authorship.count }.by 3

                a1 = Authorship.find_by(user: u1, publication: pi1.publication)
                a2 = Authorship.find_by(user: u1, publication: pi2.publication)
                a3 = Authorship.find_by(user: u2, publication: pi3.publication)
                a4 = Authorship.find_by(user: u3, publication: pi3.publication)

                expect(a1.author_number).to eq 1
                expect(a2.author_number).to eq 1
                expect(a3.author_number).to eq 1
                expect(a4.author_number).to eq 2
              end
            end
          end
        end
      end
    end
  end
end
