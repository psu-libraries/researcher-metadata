require 'component/component_spec_helper'

RSpec.describe Authorship, type: :model do
  describe 'the authorships table' do
    subject { Authorship.new }
    it { is_expected.to have_db_column(:person_id).of_type(:integer) }
    it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
    it { is_expected.to have_db_column(:author_number).of_type(:integer) }
    it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_db_index :person_id }
    it { is_expected.to have_db_index :publication_id }

    it { is_expected.to have_db_foreign_key :person_id }
    it { is_expected.to have_db_foreign_key :publication_id }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:person) }
    it { is_expected.to belong_to(:publication) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:person_id) }
    it { is_expected.to validate_presence_of(:publication_id) }
    it { is_expected.to validate_presence_of(:author_number) }
  end
end
