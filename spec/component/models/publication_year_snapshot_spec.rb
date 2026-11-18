# frozen_string_literal: true

require 'component/component_spec_helper'

describe 'the statistics_snapshots table', type: :model do
  subject { PublicationYearSnapshot.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_year).of_type(:integer) }
  it { is_expected.to have_db_column(:total_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:open_access_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to belong_to(:statistics_snapshot) }
end

describe PublicationYearSnapshot, type: :model do
  describe '#percent_open_access' do
    it 'returns the percentage of articles that were open access at the time the snapshot was taken' do
      py_snapshot = described_class.new(
        publication_year: 2026,
        total_article_count: 10,
        open_access_article_count: 5
      )
      expect(py_snapshot.percent_open_access).to eq 50
    end
  end
end
