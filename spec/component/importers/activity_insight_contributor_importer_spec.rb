require 'component/component_spec_helper'

describe ActivityInsightContributorImporter do
  let(:importer) { ActivityInsightContributorImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid contributor data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_authorships.csv') }

      context "when no contributor records exist in the database" do
        context "when a publication exists for each contributor record in the .csv" do
          let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
          let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
          let!(:pi3) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

          it "creates a new contributor record for each entry in the .csv" do
            expect { importer.call }.to change { Contributor.count }.by 5

            c1 = Contributor.find_by(publication: pi1.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
            c2 = Contributor.find_by(publication: pi2.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
            c3 = Contributor.find_by(publication: pi3.publication, first_name: 'Susan', last_name: 'Testuser', position: 1)
            c4 = Contributor.find_by(publication: pi3.publication, first_name: 'Anne', last_name: 'Author', position: 2)
            c5 = Contributor.find_by(publication: pi3.publication, first_name: 'Lowly', middle_name: 'B', last_name: 'Thirdauthor', position: 3)

            expect(c1).not_to be_nil
            expect(c2).not_to be_nil
            expect(c3).not_to be_nil
            expect(c4).not_to be_nil
            expect(c5).not_to be_nil
          end
        end

        context "when there are contributor records in the .csv without a corresponding publication" do
          let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
          let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }

          it "creates a new contributor record for each entry in the .csv that has a corresponding publication" do
            expect { importer.call }.to change { Contributor.count }.by 2

            c1 = Contributor.find_by(publication: pi1.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
            c2 = Contributor.find_by(publication: pi2.publication, first_name: 'Bob', last_name: 'Tester', position: 1)

            expect(c1).not_to be_nil
            expect(c2).not_to be_nil
          end
        end
      end

      context "when contributor records already exist for publications in the .csv" do
        let!(:existing_c1) { create :contributor, publication: pi1.publication, first_name: 'Existing', last_name: 'One' }
        let!(:existing_c2) { create :contributor, publication: pi1.publication, first_name: 'Second', last_name: 'Existing' }

        context "when a publication exists for each contributor record in the .csv" do
          let!(:pi1) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659829248' }
          let!(:pi2) {  create :publication_import, source: 'Activity Insight', source_identifier: '107659765760' }
          let!(:pi3) {  create :publication_import, source: 'Activity Insight', source_identifier: '140751927296' }

          context "when the publication with existing contributors has been updated by a human" do
            before { pi1.publication.update_column(:updated_by_user_at, Time.current ) }

            it "does not change the publication's existing contributors" do
              expect { importer.call }.to change { Contributor.count }.by 4
              expect(Contributor.count).to eq 6

              new_c = Contributor.find_by(publication: pi1.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
              expect(new_c).to be_nil

              expect(pi1.publication.contributors).to match_array [existing_c1, existing_c2]
            end

            it "creates a new record for each new contributor in the .csv" do
              importer.call

              c1 = Contributor.find_by(publication: pi2.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
              c2 = Contributor.find_by(publication: pi3.publication, first_name: 'Susan', last_name: 'Testuser', position: 1)
              c3 = Contributor.find_by(publication: pi3.publication, first_name: 'Anne', last_name: 'Author', position: 2)
              c4 = Contributor.find_by(publication: pi3.publication, first_name: 'Lowly', middle_name: 'B', last_name: 'Thirdauthor', position: 3)

              expect(c1).not_to be_nil
              expect(c2).not_to be_nil
              expect(c3).not_to be_nil
              expect(c4).not_to be_nil
            end
          end

          context "when the publication with existing contributors has not been updated by a human" do
            it "replaces the publication's existing contributors with the contributors listed in the .csv" do
              expect { importer.call }.to change { Contributor.count }.by 3
              expect(Contributor.count).to eq 5

              expect { existing_c1.reload }.to raise_error ActiveRecord::RecordNotFound
              expect { existing_c2.reload }.to raise_error ActiveRecord::RecordNotFound
            end

            it "creates a new record for each new contributor in the .csv" do
              importer.call

              c1 = Contributor.find_by(publication: pi1.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
              c2 = Contributor.find_by(publication: pi2.publication, first_name: 'Bob', last_name: 'Tester', position: 1)
              c3 = Contributor.find_by(publication: pi3.publication, first_name: 'Susan', last_name: 'Testuser', position: 1)
              c4 = Contributor.find_by(publication: pi3.publication, first_name: 'Anne', last_name: 'Author', position: 2)
              c5 = Contributor.find_by(publication: pi3.publication, first_name: 'Lowly', middle_name: 'B', last_name: 'Thirdauthor', position: 3)

              expect(c1).not_to be_nil
              expect(c2).not_to be_nil
              expect(c3).not_to be_nil
              expect(c4).not_to be_nil
              expect(c5).not_to be_nil
            end
          end
        end
      end
    end
  end
end
