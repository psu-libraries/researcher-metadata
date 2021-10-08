# frozen_string_literal: true

shared_examples_for 'an importer error log' do
  specify { expect(described_class).to be < ImporterErrorLog }
  specify { expect(described_class.table_name).to eq ImporterErrorLog.table_name }
end
