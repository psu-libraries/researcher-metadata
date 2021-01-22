require 'component/component_spec_helper'
  
describe 'the statistics_snapshots table', type: :model do
  subject { StatisticsSnapshot.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:total_publication_count).of_type(:integer) }
  it { is_expected.to have_db_column(:open_access_publication_count).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe StatisticsSnapshot, type: :model do
  before do
    create :publication, open_access_url: nil, user_submitted_open_access_url: nil
    create :publication, open_access_url: 'url1', user_submitted_open_access_url: nil
    create :publication, open_access_url: nil, user_submitted_open_access_url: 'url2'
  end

  describe ".record" do
    it "creates a new statistics snapshot record" do
      expect { StatisticsSnapshot.record }.to change { StatisticsSnapshot.count }.by 1
    end

    it "records the current total number of publications in the database" do
      snapshot = StatisticsSnapshot.record

      expect(snapshot.total_publication_count).to eq 3
    end

    it "records the current number of open access publications in the database" do
      snapshot = StatisticsSnapshot.record

      expect(snapshot.open_access_publication_count).to eq 2
    end
  end
end
