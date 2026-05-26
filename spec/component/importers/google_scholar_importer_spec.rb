# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarImporter do
  describe '#call' do
    let(:profile_importer) { instance_double(GoogleScholarProfileImporter, call: nil) }
    let(:publication_citation_importer) { instance_double(GoogleScholarPublicationCitationImporter, call: nil) }

    it 'runs profile import before publication citation import' do
      importer = described_class.new(
        profile_importer: profile_importer,
        publication_citation_importer: publication_citation_importer
      )

      expect(profile_importer).to receive(:call).ordered
      expect(publication_citation_importer).to receive(:call).ordered

      importer.call
    end
  end
end
