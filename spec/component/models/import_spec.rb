# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the imports table', type: :model do
  subject { Import.new }

  it { is_expected.to have_db_column(:source).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:started_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:completed_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe Import, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to have_many(:source_publications) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:source).in_array(['Pure', 'Activity Insight']) }
  end
end
