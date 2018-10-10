require 'component/component_spec_helper'

describe ActivityInsightPublicationImporter do
  let(:importer) { ActivityInsightPublicationImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid publication data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_publications.csv') }

      context "when no publication records exist in the database" do
        it "creates a new publication record for every row in the .csv file that represents a journal article" do
          expect { importer.call }.to change { Publication.count }.by 3
        end
      end
    end
  end
end
