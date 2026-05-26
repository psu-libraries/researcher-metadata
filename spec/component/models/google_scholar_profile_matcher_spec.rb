# frozen_string_literal: true

require 'component/component_spec_helper'

describe GoogleScholarProfileMatcher, type: :model do
  describe '#match' do
    let(:user) { create(:user, :with_psu_identity) }

    context 'when two candidate publication DOIs match the user publications' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/second')
      end

      let(:profile) do
        {
          publications: [
            { title: 'First Scholar Article', doi: '10.123/first' },
            { title: 'Second Scholar Article', doi: 'https://doi.org/10.123/second' }
          ]
        }
      end

      it 'matches by DOI' do
        result = described_class.new(user, profile).match

        expect(result).to be_matched
        expect(result.strategy).to eq :doi
        expect(result.match_count).to eq 2
      end
    end

    context 'when fewer than two DOIs match' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
      end

      let(:profile) do
        {
          publications: [
            { title: 'First Scholar Article', doi: '10.123/first' },
            { title: 'Unrelated Scholar Article', doi: '10.123/unrelated' }
          ]
        }
      end

      it 'does not match by DOI' do
        result = described_class.new(user, profile).match

        expect(result).not_to be_matched
      end
    end

    context 'when title matching is needed as a fallback' do
      before do
        create(:sample_publication, user: user, title: 'Machine Learning in Libraries', secondary_title: nil)
        create(:sample_publication, user: user, title: 'Metadata Workflows for Researchers', secondary_title: nil)
      end

      let(:profile) do
        {
          publications: [
            { title: 'Machine Learning in Libraries', doi: nil },
            { title: 'Metadata Workflows for Researchers', doi: nil }
          ]
        }
      end

      it 'matches by title' do
        result = described_class.new(user, profile).match

        expect(result).to be_matched
        expect(result.strategy).to eq :title
        expect(result.match_count).to eq 2
      end
    end
  end
end
