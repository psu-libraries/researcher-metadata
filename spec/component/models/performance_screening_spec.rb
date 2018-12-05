require 'component/component_spec_helper'
  
describe 'the performance screening table', type: :model do
  subject { PerformanceScreening.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:performance_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:screening_type) }
  it { is_expected.to have_db_column(:name) }
  it { is_expected.to have_db_column(:location) }
  it { is_expected.to have_db_column(:activity_insight_id).with_options(null: false) }

  it { is_expected.to have_db_index(:activity_insight_id).unique(true) }
  it { is_expected.to have_db_index(:performance_id) }
  it { is_expected.to have_db_foreign_key(:performance_id) }
end

describe PerformanceScreening, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:performance) }
    it { is_expected.to validate_presence_of(:activity_insight_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:performance) }
  end
end
