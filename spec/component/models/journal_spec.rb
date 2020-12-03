require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the journals table', type: :model do
  subject { Journal.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:publisher_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :publisher_id }

  it { is_expected.to have_db_foreign_key(:publisher_id) }
end

describe Journal, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:publisher).inverse_of(:journals) }
  end
end
