# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the open_access_locations table', type: :model do
  subject { OpenAccessLocation.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
  it { is_expected.to have_db_column(:host_type).of_type(:string) }
  it { is_expected.to have_db_column(:is_best).of_type(:boolean) }
  it { is_expected.to have_db_column(:license).of_type(:string) }
  it { is_expected.to have_db_column(:oa_date).of_type(:date) }
  it { is_expected.to have_db_column(:source).of_type(:string) }
  it { is_expected.to have_db_column(:source_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:url).of_type(:string) }
  it { is_expected.to have_db_column(:landing_page_url).of_type(:string) }
  it { is_expected.to have_db_column(:pdf_url).of_type(:string) }
  it { is_expected.to have_db_column(:version).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe OpenAccessLocation, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:open_access_locations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:publication) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:url) }

    it { is_expected.to validate_inclusion_of(:source).in_array(described_class.sources) }
  end

  describe '.sources' do
    it 'returns an array of the possible sources of open access location data' do
      expect(described_class.sources).to eq ['User', 'ScholarSphere', 'Open Access Button', 'Unpaywall']
    end
  end
end
