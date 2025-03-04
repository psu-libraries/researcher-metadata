# frozen_string_literal: true

require 'component/component_spec_helper'

describe DOIVerificationService do
  let(:publication) { create(:publication,
                             doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9',
                             title: title,
                             secondary_title: secondary_title,
                             doi_verified: nil)}
  let(:title) { 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford' }
  let(:secondary_title) { 'Theories of change for psychotherapy integration' }
  let(:service) { described_class.new(publication) }
  let(:json) { Rails.root.join('spec', 'fixtures', 'unpaywall2.json').read }

  describe '#verify' do
    before { allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/10.1016/S0962-1849(05)80014-9?email=openaccess@psu.edu').and_return(json) }

    context 'when the publication title matches exactly' do
      let(:title) { 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be true
      end
    end

    context 'when the publication is of type Extension Publication' do
      let(:extension_publication) { create(:publication,
                                           doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9',
                                           title: title,
                                           publication_type: 'Extension Publication',
                                           secondary_title: secondary_title,
                                           doi_verified: nil)}

      let(:service_b) { described_class.new(extension_publication) }

      it 'does not proceed to check the doi' do
        service_b.verify
        expect(HttpService).not_to have_received(:get)
        expect(extension_publication.reload.doi_verified).to be_nil
      end
    end

    context 'when the publication title matches but has different punctuation and casing' do
      let(:title) { 'Psychotherapy Integration, and the Need for Better Theories of Change: A Rejoinder to Alford' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be true
      end
    end

    context 'when titles have at least 70% similarity' do
      let(:title) { 'Psychotherapy integration and the need for better theories of change' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be true
      end
    end

    context 'when titles have less than 70% similarity' do
      let(:title) { 'Psychotherapy Integration: Theories of Change' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be false
      end
    end
  end
end
