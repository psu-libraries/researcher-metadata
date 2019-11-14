require 'unit/unit_spec_helper'
require_relative '../../../app/decorators/authorship_decorator'

describe AuthorshipDecorator do
  let(:auth) { double 'authorship',
                       publication_title: 'Test Title',
                       publication_published_by: 'A Journal',
                       publication_year: 2000,
                       publication_open_access_url: url }
  let(:url) { nil }
  let(:ad) { AuthorshipDecorator.new(auth) }

  describe '#class' do
    it "returns the class name of the wrapped object" do
      expect(ad.class).to eq RSpec::Mocks::Double
    end
  end

  describe "#label" do
    context "when the authorship has a publication open access URL" do
      let(:url) { "https://example.org/pubs/1" }

      it "returns a label for the authorship with a publication link" do
        expect(ad.label).to eq %{<a href="https://example.org/pubs/1" target="_blank">Test Title</a> - A Journal - 2000}
      end
    end
    context "when the authorship does not have a publication open access URL" do
      it "returns a label for the authorship with no publication link" do
        expect(ad.label).to eq "Test Title - A Journal - 2000"
      end
    end
  end
end
