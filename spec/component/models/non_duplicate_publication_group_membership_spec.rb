# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the nonduplicate_publication_group_memberships table', type: :model do
  subject { NonDuplicatePublicationGroupMembership.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:non_duplicate_publication_group_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :publication_id }
  it { is_expected.to have_db_index :non_duplicate_publication_group_id }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_foreign_key(:non_duplicate_publication_group_id) }
end

describe NonDuplicatePublicationGroupMembership, type: :model do
  subject { described_class.new }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:non_duplicate_group_memberships) }
    it { is_expected.to belong_to(:non_duplicate_group).class_name(:NonDuplicatePublicationGroup).inverse_of(:memberships) }
  end
end
