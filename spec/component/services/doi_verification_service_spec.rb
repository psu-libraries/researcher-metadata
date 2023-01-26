# frozen_string_literal: true

require 'component/component_spec_helper'

describe DoiVerificationService do
  let(:publication) { create(:publication,
                             doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9',
                             title: title,
                             secondary_title: secondary_title,
                             doi_verified: nil)}
  let(:title) { 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford' }
  let(:secondary_title) { nil }
  let(:service) { described_class.new(publication) }

  describe '#verify' do
    context 'when the publication title matches exactly' do
      let(:title) { 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be true
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

    context 'when the publication has a secondary title' do
      let(:title) { 'Psychotherapy integration and the need for better theories of change' }
      let(:secondary_title) { 'A rejoinder to Alford' }

      it 'updates the doi verified status in publication record' do
        service.verify
        expect(publication.reload.doi_verified).to be true
      end
    end
  end
end
