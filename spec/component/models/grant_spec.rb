require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the grants table', type: :model do
  subject { Grant.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:agency_name).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:identifier).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:identifier) }
end

describe Grant, type: :model do
  subject(:grant) { Grant.new }

  it_behaves_like "an application record"

  it { is_expected.to have_many(:research_funds) }
  it { is_expected.to have_many(:publications).through(:research_funds) }

  it { is_expected.to validate_presence_of(:agency_name) }
end
