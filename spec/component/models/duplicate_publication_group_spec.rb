require 'component/component_spec_helper'

describe 'the duplicate_publication_groups table', type: :model do
  subject { DuplicatePublicationGroup.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:journal).of_type(:text) }
  it { is_expected.to have_db_column(:issue).of_type(:string) }
  it { is_expected.to have_db_column(:volume).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe DuplicatePublicationGroup, type: :model do
  subject(:contributor) { DuplicatePublicationGroup.new }

  it { is_expected.to have_many :publications }
end
