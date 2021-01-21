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
  
end
