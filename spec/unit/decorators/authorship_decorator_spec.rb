require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/decorators/authorship_decorator'

describe AuthorshipDecorator do
  let(:auth) { double 'authorship',
                       title: title,
                       published_by: publisher,
                       year: year,
                       preferred_open_access_url: url }
  let(:title) { '' }
  let(:publisher) { '' }
  let(:year) { '' }
  let(:url) { '' }
  let(:ad) { AuthorshipDecorator.new(auth) }

  describe '#class' do
    it "returns the class name of the wrapped object" do
      expect(ad.class).to eq RSpec::Mocks::Double
    end
  end

  describe "#label" do
    context "when the given object has an open access URL" do
      let(:url) { "https://example.org/pubs/1" }

      context "when the given objet has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link, publisher, and year" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link and publisher" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link and year" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>}
            end
          end
        end
      end
    end

    context "when the given object does not have an open access URL" do
      context "when the given objet has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication title, publisher, and year" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication title and publisher" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication title and year" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication title" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>}
            end
          end
        end
      end
    end
  end
end
