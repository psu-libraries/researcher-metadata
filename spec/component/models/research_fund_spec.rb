# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the research_funds table', type: :model do
  subject { ResearchFund.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:grant_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :grant_id }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:grant_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe ResearchFund, type: :model do
  subject(:grant) { described_class.new }

  it_behaves_like 'an application record'

  it { is_expected.to belong_to(:grant).inverse_of(:research_funds) }
  it { is_expected.to belong_to(:publication).inverse_of(:research_funds) }

  it { is_expected.to validate_presence_of(:grant_id) }
  it { is_expected.to validate_presence_of(:publication_id) }
end
