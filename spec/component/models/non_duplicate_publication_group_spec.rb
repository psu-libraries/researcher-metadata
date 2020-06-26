require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the non_duplicate_publication_groups table', type: :model do
  subject { NonDuplicatePublicationGroup.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe NonDuplicatePublicationGroup, type: :model do
  subject(:ndpg) { NonDuplicatePublicationGroup.new }

  it_behaves_like "an application record"

  it { is_expected.to have_many(:memberships).class_name(:NonDuplicatePublicationGroupMembership).inverse_of(:non_duplicate_group) }
  it { is_expected.to have_many(:publications).through(:memberships) }
end
