require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the publishers table', type: :model do
  subject { Publisher.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:name).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe Publisher, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to have_many(:journals).inverse_of(:publisher) }
  end
end
