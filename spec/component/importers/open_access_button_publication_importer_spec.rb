require 'component/component_spec_helper'

describe OpenAccessButtonPublicationImporter do
  let(:importer) { OpenAccessButtonPublicationImporter.new }
  let!(:pub1) { create :publication, doi: 'https://doi.org/pub/doi1' }

  before do
    allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=pub/doi1").
      and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab1.json')))
  end

  describe '#call' do
    it "finds any open access content URLs for existing publications with DOIs and saves them" do
      importer.call
      expect(pub1.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
    end
  end
end
