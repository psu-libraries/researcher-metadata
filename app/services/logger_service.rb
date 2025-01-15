# frozen_string_literal: true

class LoggerService
  def destroy_old_importer_error_logs
    ImporterErrorLog.older_than_six_months.find_each(&:destroy)
  end
end
