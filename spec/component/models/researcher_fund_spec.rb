# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the researcher_funds table', type: :model do
  subject { ResearcherFund.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:grant_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:import_source).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :grant_id }
  it { is_expected.to have_db_index :user_id }

  it { is_expected.to have_db_foreign_key(:grant_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe ResearcherFund, type: :model do
  subject(:grant) { described_class.new }

  it_behaves_like 'an application record'

  it { is_expected.to belong_to(:grant).inverse_of(:researcher_funds) }
  it { is_expected.to belong_to(:user).inverse_of(:researcher_funds) }

  it { is_expected.to validate_presence_of(:grant_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_inclusion_of(:import_source).in_array(['NSF', 'NIH']).allow_nil }

  describe '.import_sources' do
    it 'returns the list of possible import data sources for a researcher fund' do
      expect(described_class.import_sources).to eq ['NSF', 'NIH']
    end
  end
end
