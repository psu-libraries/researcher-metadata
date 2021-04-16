require 'component/component_spec_helper'
  
describe 'the statistics_snapshots table', type: :model do
  subject { StatisticsSnapshot.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:total_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:open_access_article_count).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe StatisticsSnapshot, type: :model do
  before do
    create :publication, open_access_url: nil, user_submitted_open_access_url: nil
    create :publication, open_access_url: 'url1', user_submitted_open_access_url: nil
    create :publication, open_access_url: nil, user_submitted_open_access_url: 'url2'
    create :publication, open_access_url: nil, user_submitted_open_access_url: 'url3', publication_type: 'Book'
  end

  describe ".record" do
    it "creates a new statistics snapshot record" do
      expect { StatisticsSnapshot.record }.to change { StatisticsSnapshot.count }.by 1
    end

    it "records the current total number of articles in the database" do
      snapshot = StatisticsSnapshot.record

      expect(snapshot.total_article_count).to eq 3
    end

    it "records the current number of open access articles in the database" do
      snapshot = StatisticsSnapshot.record

      expect(snapshot.open_access_article_count).to eq 2
    end
  end

  describe '#percent_open_access' do
    let(:snapshot) { build :statistics_snapshot,
                           total_article_count: 3,
                           open_access_article_count: 2 }

    it "returns the percentage of articles that were open access at the time the snapshot was taken" do
      expect(snapshot.percent_open_access).to eq 66.7
    end
  end
end
