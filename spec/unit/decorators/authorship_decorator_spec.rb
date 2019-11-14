require 'unit/unit_spec_helper'
require_relative '../../../app/decorators/authorship_decorator'

describe AuthorshipDecorator do
  let(:auth) { double 'authorship',
                       publication_title: 'Test Title',
                       publication_published_by: 'A Journal',
                       publication_year: 2000 }
  let(:ad) { AuthorshipDecorator.new(auth) }

  describe '#class' do
    it "returns the class name of the wrapped object" do
      expect(ad.class).to eq RSpec::Mocks::Double
    end
  end

  describe "#label" do
    it "returns a label for the authorship by formatting its publication data" do
      expect(ad.label).to eq "Test Title - A Journal - 2000"
    end
  end
end
