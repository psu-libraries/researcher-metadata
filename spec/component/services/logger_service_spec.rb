# frozen_string_literal: true

require 'component/component_spec_helper'

describe LoggerService do
  let(:service) { described_class.new }
  describe '#destroy_old_importer_error_logs' do
    let! (:old_error) {create(:importer_error_log, created_at: DateTime.now - 1.year)}
    let! (:old_error_2) {create(:importer_error_log, created_at: DateTime.now - 7.months)}
    let! (:recent_error) {create(:importer_error_log, created_at: DateTime.now)}

    it 'destroys all older_than_six_months scope error logs' do
      older_errors = ImporterErrorLog.older_than_six_months
      expect(ImporterErrorLog.count).to eql(3)
      service.destroy_old_importer_error_logs
      expect(ImporterErrorLog.count).to eql(1)
      expect(ImporterErrorLog.all).to include(recent_error)
      older_errors.each do |e|
        expect(ImporterErrorLog.all).not_to include(e)
      end
    end
  end
end
