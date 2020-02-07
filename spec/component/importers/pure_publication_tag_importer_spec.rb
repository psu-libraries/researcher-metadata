require 'component/component_spec_helper'

describe PurePublicationTagImporter do
  let(:importer) { PurePublicationTagImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .json file of publicaiton fingerprint data from Pure" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'pure_publication_fingerprints.json') }

      context "when no publications in the database match the publication data being imported" do
        it "runs" do
          expect { importer.call }.not_to raise_error
        end

        it "does not create any new tags" do
          expect { importer.call }.not_to change { Tag.count }
        end
      end

      context "when publications in the database match the publication data being imported" do
        let!(:imp1) { create :publication_import,
                             source: "Pure",
                             source_identifier: "e1b21d75-4579-4efc-9fcc-dcd9827ee51a",
                             publication: pub1 }
        let!(:imp2) { create :publication_import,
                             source: "Pure",
                             source_identifier: "890420eb-eff9-4cbc-8e1b-20f68460f4eb",
                             publication: pub2 }

        let!(:pub1) { create :publication }
        let!(:pub2) { create :publication }

        it "runs" do
          expect { importer.call }.not_to raise_error
        end
        
        it "creates new tags" do
          expect { importer.call }.to change { Tag.count }
        end
      end
    end
  end
end
