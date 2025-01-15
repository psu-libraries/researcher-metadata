# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the import_error_logs table', type: :model do
  subject { ImporterErrorLog.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:importer_type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:error_type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:error_message).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:stacktrace).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:metadata).of_type(:jsonb) }
  it { is_expected.to have_db_column(:occurred_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:importer_type) }
end

describe ImporterErrorLog, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:error_type) }
    it { is_expected.to validate_presence_of(:stacktrace) }
    it { is_expected.to validate_presence_of(:occurred_at) }
  end

  describe 'older_than_six_months' do
    let!(:recent_log) { create(:importer_error_log) }
    let(:older_log) { create(:importer_error_log, created_at: DateTime.now - 7.months) }

    it do
      expect(described_class.older_than_six_months).not_to include(recent_log)
      expect(described_class.older_than_six_months).to include(older_log)
    end
  end

  describe '.log_error' do
    it 'creates an error log with the given params' do
      raise 'my error'
    rescue RuntimeError => e
      log = described_class.log_error(
        importer_class: ActivityInsightImporter,
        error: e,
        metadata: { key: 'val' }
      )

      expect(log).to be_persisted
      expect(log.importer_type).to eq 'ActivityInsightImporter'
      expect(log.error_type).to eq 'RuntimeError'
      expect(log.error_message).to eq 'my error'
      expect(log.metadata['key']).to eq 'val'
      expect(log.occurred_at).to be_within(5.seconds).of(Time.zone.now)
      expect(log.stacktrace).to be_present
    end
  end
end
