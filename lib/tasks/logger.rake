# frozen_string_literal: true

desc 'Remove all ImporterLogErrors older than 6 months'
task remove_importer_error_logs: :environment do
  LoggerService.new.destroy_old_importer_error_logs
end
