require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the committee_memberships table', type: :model do
  subject { CommitteeMembership.new }

  it { is_expected.to have_db_column(:etd_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:role).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :etd_id }
  it { is_expected.to have_db_index :user_id }

  it { is_expected.to have_db_foreign_key(:etd_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe CommitteeMembership, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:etd).inverse_of(:committee_memberships) }
    it { is_expected.to belong_to(:user).inverse_of(:committee_memberships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:etd_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:role) }

    context "given otherwise valid data" do
      subject { CommitteeMembership.new(etd: create(:etd), user: create(:user), role: 'Advisor') }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:etd_id, :role) }
    end
  end
end
