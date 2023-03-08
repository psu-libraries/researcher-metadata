# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

RSpec.describe ActivityInsightOAFile, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:location).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:version).of_type(:string) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_index :publication_id }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:activity_insight_oa_files) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:version).in_array(described_class::ALLOWED_VERSIONS).allow_nil }
  end

  describe '#version_status_display' do
    context 'when version is "unknown"' do
      let(:file) { create(:activity_insight_oa_file, version: 'unknown') }

      it 'returns "Unknown Version"' do
        expect(file.version_status_display).to eq 'Unknown Version'
      end
    end

    context 'when version is "acceptedVersion"' do
      let(:file) { create(:activity_insight_oa_file, version: 'acceptedVersion') }

      it 'returns "Wrong Version"' do
        expect(file.version_status_display).to eq 'Wrong Version'
      end
    end
  end
end
