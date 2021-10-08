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
end
