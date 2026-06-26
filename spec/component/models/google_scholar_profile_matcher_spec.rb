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

    context 'when the Scholar profile has a verified psu.edu email' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/only-one')
      end

      let(:profile) do
        {
          email_domain: 'psu.edu',
          affiliation: 'Materials Research Institute, Pennsylvania State University',
          publications: [
            { title: 'Some Scholar Paper', doi: '10.123/only-one' }
          ]
        }
      end

      it 'matches with a single DOI match (PSU confirmed lowers the threshold)' do
        result = described_class.new(user, profile).match

        expect(result).to be_matched
        expect(result.strategy).to eq :doi
        expect(result.match_count).to eq 1
      end
    end

    context 'when the Scholar profile has a verified psu.edu email and a single title match' do
      before do
        create(:sample_publication, user: user, title: 'Subversion as Public Value', secondary_title: nil)
      end

      let(:profile) do
        {
          email_domain: 'psu.edu',
          affiliation: 'Assistant Teaching Professor, Penn State Harrisburg',
          publications: [
            { title: 'Subversion as Public Value', doi: nil }
          ]
        }
      end

      it 'matches by a single title (PSU confirmed lowers the title threshold)' do
        result = described_class.new(user, profile).match

        expect(result).to be_matched
        expect(result.strategy).to eq :title
        expect(result.match_count).to eq 1
      end
    end

    context 'when the Scholar profile has a non-PSU verified email' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/first')
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/second')
        create(:sample_publication, user: user, title: 'Machine Learning in Libraries', secondary_title: nil)
        create(:sample_publication, user: user, title: 'Metadata Workflows for Researchers', secondary_title: nil)
      end

      let(:profile) do
        {
          email_domain: 'umich.edu',
          publications: [
            { title: 'Machine Learning in Libraries', doi: '10.123/first' },
            { title: 'Metadata Workflows for Researchers', doi: '10.123/second' }
          ]
        }
      end

      it 'rejects the match even when two DOIs overlap' do
        result = described_class.new(user, profile).match

        expect(result).not_to be_matched
        expect(result.strategy).to eq :institution
      end

      it 'rejects the match even when two titles overlap' do
        title_only_profile = {
          email_domain: 'umich.edu',
          publications: [
            { title: 'Machine Learning in Libraries', doi: nil },
            { title: 'Metadata Workflows for Researchers', doi: nil }
          ]
        }
        result = described_class.new(user, title_only_profile).match

        expect(result).not_to be_matched
        expect(result.strategy).to eq :institution
      end
    end

    context 'when the Scholar profile has no affiliation data' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/only-one')
      end

      let(:profile) do
        {
          email_domain: nil,
          affiliation: nil,
          publications: [
            { title: 'Some Scholar Paper', doi: '10.123/only-one' }
          ]
        }
      end

      it 'does not match on a single DOI (falls back to strict threshold)' do
        result = described_class.new(user, profile).match

        expect(result).not_to be_matched
      end
    end

    context 'when the Scholar profile affiliation text contains Penn State (no email)' do
      before do
        create(:sample_publication, user: user, doi: 'https://doi.org/10.123/only-one')
      end

      let(:profile) do
        {
          email_domain: nil,
          affiliation: 'Department of Physics, Pennsylvania State University',
          publications: [
            { title: 'Some Scholar Paper', doi: '10.123/only-one' }
          ]
        }
      end

      it 'matches with a single DOI match (affiliation text confirms PSU)' do
        result = described_class.new(user, profile).match

        expect(result).to be_matched
        expect(result.strategy).to eq :doi
      end
    end
  end
end
