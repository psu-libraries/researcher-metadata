# frozen_string_literal: true

require 'component/component_spec_helper'

describe DoiVerificationService do
  let(:publication) { create :publication,
                              doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9',
                              title: title,
                              secondary_title: secondary_title,
                              doi_verified: nil}
  let(:title) { 'Psychotherapy integration and the need for better theories of change'}
  let(:secondary_title) {nil}
  let(:service) { described_class.new(publication) }
    describe '#verify' do
      before do
        allow(HttpService).to receive(:get).with('https://api.unpaywall.org/v2/10.1016/S0962-1849(05)80014-9?email=openaccess@psu.edu').and_return("{\"title\": \"Psychotherapy integration and the need for better theories of change: A rejoinder to Alford\"}")
      end

      context 'when the publication title matches exactly' do
        it 'updates the doi verified status in publication record' do
            service.verify
            expect(publication.reload.doi_verified).to eq true
        end
      end

      context 'when the publication title matches but has different punctuation and casing' do
        let(:title) {'Psychotherapy Integration: and the Need for Better, theories of change'}
        it 'updates the doi verified status in publication record' do
            service.verify
            expect(publication.reload.doi_verified).to eq true
        end
      end
    end
#secondary title is it's own context
    # describe '#get_unpaywall_data' do
    #     it 'returns the publciation title' do

    #     end
    # end

    # describe '#compare_title' do
    #     context 'when titles are an exact match' do
    #     it 'returns true' do
    #         result = service.compare_title(publication.title, publication.title)
    #         expect(result).to eq true
    #     end
    #     end

    #     context 'when titles are a match but have different punctuation and casing' do
    #     let(:title2) { 'Psychotherapy Integration: and the Need for Better Theories of Change' }
    #     it 'returns true' do
    #         result = service.compare_title(publication.title, title2)
    #         expect(result).to eq true
    #     end
    #     end

    #     context 'when titles have at least 70% similarity' do
    #     let(:title2) { 'Psychotherapy integration: need for better theories of change' }
    #     it 'returns true' do
    #         result = service.compare_title(publication.title, title2)
    #         expect(result).to eq true
    #     end
    #     end

    #     context 'when titles have less than 70% similarity' do
    #     let(:title2) { 'Psychotherapy Integration: Theories of Change' }
    #     it 'returns false' do
    #         result = service.compare_title(publication.title, title2)
    #         expect(result).to eq false
    #     end
    #   end
    # end
end
