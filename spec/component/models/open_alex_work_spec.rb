# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexWork do
  let(:work) { described_class.new(work_data) }
  let(:work_data) {
    {
      'doi' => 'test-doi',
      'title' => title,
      'type' => 'dataset',
      'publication_date' => '2026-06-01',
      'id' => 'oa-id-123',
      'updated_date' => '2026-05-21T06:26:12.895304',
      'locations' => locations,
      'open_access' => {
        'oa_status' => 'green'
      },
      'primary_location' => {
        'id' => 'abc123',
        'is_published' => false
      },
      'best_oa_location' => {
        'id' => 'def456',
        'is_published' => true
      },
      'authorships' => [
        { 'author' => { 'id' => 'abc123' } },
        { 'author' => { 'id' => 'def456' } }
      ]
    }
  }
  let(:title) { 'Test Dataset' }
  let(:locations) {
    [
      {
        'id' => 'abc123',
        'is_published' => false
      },
      {
        'id' => 'def456',
        'is_published' => true
      }
    ]
  }
  let(:doi_sanitizer) {
    instance_double(
      DOISanitizer,
      url: 'doi-url'
    )
  }
  let(:loc_1) {
    instance_double(
      OpenAlexLocation,
      id: 'abc123',
      published?: false,
      name: 'Test Repo',
      pdf_url: pdf_url
    )
  }
  let(:loc_2) {
    instance_double(
      OpenAlexLocation,
      id: 'def456',
      published?: true
    )
  }
  let(:pdf_url) { nil }
  let(:auth_1) { instance_double(OpenAlexAuthor, psu_affiliated?: false) }
  let(:auth_2) { instance_double(OpenAlexAuthor, psu_affiliated?: true) }

  before do
    allow(DOISanitizer).to receive(:new).with('test-doi').and_return doi_sanitizer
    allow(OpenAlexLocation).to receive(:new).with(
      { 'id' => 'abc123', 'is_published' => false }, work
    ).and_return loc_1
    allow(OpenAlexLocation).to receive(:new).with(
      { 'id' => 'def456', 'is_published' => true }, work
    ).and_return loc_2
    allow(OpenAlexAuthor).to receive(:new).with({ 'author' => { 'id' => 'abc123' } }, 0).and_return auth_1
    allow(OpenAlexAuthor).to receive(:new).with({ 'author' => { 'id' => 'def456' } }, 1).and_return auth_2
  end

  describe '#doi' do
    it 'returns the DOI from the given metadata' do
      expect(work.doi).to eq 'doi-url'
    end
  end

  describe '#title' do
    it 'returns the title from the given metadata' do
      expect(work.title).to eq 'Test Dataset'
    end
  end

  describe '#type' do
    it 'returns the work type from the given metadata' do
      expect(work.type).to eq 'Dataset'
    end
  end

  describe '#publication_date' do
    it 'returns the date of publication from the given metadata' do
      expect(work.publication_date).to eq Date.new(2026, 6, 1)
    end
  end

  describe '#open_alex_identifier' do
    it 'returns the Open Alex identifier for the work from the given metadata' do
      expect(work.open_alex_identifier).to eq 'oa-id-123'
    end
  end

  describe '#updated_at' do
    it 'returns the time when the metadata for the work was last updated in Open Alex' do
      expect(work.updated_at).to be_within(1.second).of(Time.new(2026, 5, 21, 6, 26, 12))
    end
  end

  describe '#importable?' do
    context 'when the work metadata contains no locations' do
      let(:locations) { [] }

      context 'when the work metadata includes a title' do
        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end

      context 'when the work metadata includes a blank title' do
        let(:title) { '' }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end

      context 'when the work metadata does not include a title' do
        let(:title) { nil }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end
    end

    context 'when the work metadata has only an unpublished location' do
      let(:locations) {
        [
          {
            'id' => 'abc123',
            'is_published' => false
          }
        ]
      }

      context 'when the work metadata includes a title' do
        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end

      context 'when the work metadata includes a blank title' do
        let(:title) { '' }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end

      context 'when the work metadata does not include a title' do
        let(:title) { nil }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end
    end

    context 'when the work metadata has a published location' do
      context 'when the work metadata includes a title' do
        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns true' do
            expect(work.importable?).to be true
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns true' do
            expect(work.importable?).to be true
          end
        end
      end

      context 'when the work metadata includes a blank title' do
        let(:title) { '' }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end

      context 'when the work metadata does not include a title' do
        let(:title) { nil }

        context 'when the work metadata includes a PDF URL for the primary location' do
          let(:pdf_url) { 'https://test.com/pdf' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata includes a blank PDF URL for the primary location' do
          let(:pdf_url) { '' }

          it 'returns false' do
            expect(work.importable?).to be false
          end
        end

        context 'when the work metadata does not include a PDF URL for the primary location' do
          it 'returns false' do
            expect(work.importable?).to be false
          end
        end
      end
    end
  end

  describe '#oa_status' do
    it 'returns the open access status of the work from the given metadata' do
      expect(work.oa_status).to eq 'green'
    end
  end

  describe '#publisher' do
    it "returns the name of the work's primary location" do
      expect(work.publisher).to eq 'Test Repo'
    end
  end

  describe '#locations' do
    it "returns an OpenAlexLocation for each of the work's locations in the given metadata" do
      expect(work.locations).to eq [loc_1, loc_2]
    end
  end

  describe '#best_oa_location_id' do
    it "returns the ID of the work's best open access location from the given metadata" do
      expect(work.best_oa_location_id).to eq 'def456'
    end
  end

  describe '#all_authors' do
    it "returns an OpenAlexAuthor for each of the work's authors in the given metadata" do
      expect(work.all_authors).to eq [auth_1, auth_2]
    end
  end

  describe '#psu_authors' do
    it "returns an OpenAlexAuthor for each of the work's authors that are affiliated with Penn State in the given metadata" do
      expect(work.psu_authors).to eq [auth_2]
    end
  end
end
