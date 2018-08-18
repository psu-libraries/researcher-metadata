require 'component/component_spec_helper'

describe 'the tags_table', type: :model do
  subject { Tag.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:name) }
end

describe Tag, type: :model do
  subject(:tag) { Tag.new }

  it { is_expected.to validate_presence_of :name }
end
