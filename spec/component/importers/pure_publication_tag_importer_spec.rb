require 'component/component_spec_helper'

describe PurePublicationTagImporter do
  let(:importer) { PurePublicationTagImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .json file of publicaiton fingerprint data from Pure" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'pure_publication_fingerprints.json') }

      it "runs" do
        expect { importer.call }.not_to raise_error
      end
    end
  end
end
