require 'component/component_spec_helper'

describe 'the user_performances table', type: :model do
  subject { UserPerformance.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:performance_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:activity_insight_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:visible_in_profile).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:position_in_profile).of_type(:integer) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :performance_id }
  it { is_expected.to have_db_index(:activity_insight_id).unique(true) }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:performance_id) }
end

describe UserPerformance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:user_performances) }
    it { is_expected.to belong_to(:performance).inverse_of(:user_performances) }
  end

  describe 'deleting a performance with user_performances' do
    let(:p) { create :performance }
    let!(:up) { create :user_performance, performance: p }

    it "also deletes the performance's user_performances" do
      p.destroy
      expect { up.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:performance_id) }
    it { is_expected.to validate_presence_of(:activity_insight_id) }
  end

  it { is_expected.to delegate_method(:performance_title).to(:performance).as(:title) }
  it { is_expected.to delegate_method(:performance_location).to(:performance).as(:location) }
  it { is_expected.to delegate_method(:performance_start_on).to(:performance).as(:start_on) }
  it { is_expected.to delegate_method(:user_webaccess_id).to(:user).as(:webaccess_id) }
  it { is_expected.to delegate_method(:user_first_name).to(:user).as(:first_name) }
  it { is_expected.to delegate_method(:user_last_name).to(:user).as(:last_name) }
end
