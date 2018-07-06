require 'component/component_spec_helper'

RSpec.describe User, type: :model do
  describe 'the users table' do
    subject { User.new }
    it { is_expected.to have_db_column(:webaccess_id).of_type(:string) }
    it { is_expected.to have_db_column(:person_id).of_type(:integer) }
    it { is_expected.to have_db_column(:is_admin).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_db_index :person_id }
    it { is_expected.to have_db_index :webaccess_id }

    it { is_expected.to have_db_foreign_key :person_id }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:person) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:webaccess_id) }
    it { is_expected.to validate_presence_of(:person_id) }
  end
end
