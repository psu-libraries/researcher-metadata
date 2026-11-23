# frozen_string_literal: true

require 'component/component_spec_helper'

describe 'the statistics_snapshots table', type: :model do
  subject { StatisticsSnapshot.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:total_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:open_access_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_many(:publication_year_snapshots) }
end

describe StatisticsSnapshot, type: :model do
  before do
    create(:publication, open_access_locations: [], published_on: DateTime.new(2026, 1, 1))
    create(:publication, open_access_locations: [build(:open_access_location,
                                                       source: Source::OPEN_ACCESS_BUTTON,
                                                       url: 'url1')], published_on: DateTime.new(2025, 5, 5))
    create(:publication, open_access_locations: [build(:open_access_location,
                                                       source: Source::USER,
                                                       url: 'url2')], published_on: DateTime.new(2018, 2, 14))
    create(:publication, publication_type: 'Book', open_access_locations: [build(:open_access_location,
                                                                                 source: Source::USER,
                                                                                 url: 'url3')])
  end

  describe '.record' do
    it 'creates a new statistics snapshot record' do
      expect { described_class.record }.to change(described_class, :count).by 1
    end

    it 'records the current total number of articles in the database' do
      snapshot = described_class.record
      expect(snapshot.total_article_count).to eq 3
    end

    it 'records the current number of open access articles in the database' do
      snapshot = described_class.record

      expect(snapshot.open_access_article_count).to eq 2
    end

    it 'creates a PublicationYearSnapshot for each year going back to 2019' do
      described_class.record
      expect(PublicationYearSnapshot.count).to be 2
      pub_year_2026 = PublicationYearSnapshot.where(publication_year: 2026).first
      pub_year_2025 = PublicationYearSnapshot.where(publication_year: 2025).first
      expect(PublicationYearSnapshot.where(publication_year: 2018).count).to be 0
      expect(pub_year_2026.total_article_count).to eq 1
      expect(pub_year_2026.open_access_article_count).to eq 0
      expect(pub_year_2025.total_article_count).to eq 1
      expect(pub_year_2025.open_access_article_count).to eq 1
    end
  end

  describe '#percent_open_access' do
    let(:snapshot) { build(:statistics_snapshot,
                           total_article_count: 3,
                           open_access_article_count: 2) }

    it 'returns the percentage of articles that were open access at the time the snapshot was taken' do
      expect(snapshot.percent_open_access).to eq 66.7
    end
  end
end
