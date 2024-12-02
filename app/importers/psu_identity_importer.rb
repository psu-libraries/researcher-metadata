# frozen_string_literal: true

class PSUIdentityImporter
  DEFAULT_WAIT_TIME = 0.1

  def call
    User.find_each do |user|
      PSUIdentityUserService.find_or_initialize_user(webaccess_id: user.webaccess_id)
      progress_bar.increment
      sleep DEFAULT_WAIT_TIME
    rescue StandardError => e
      log_error(e, user)
    end
    progress_bar.finish
  rescue StandardError => e
    log_error(e)
  end

  private

    def progress_bar
      @progress_bar ||= Utilities::ProgressBarTTY.create(title: 'Importing data from Penn State Identity API', total: User.count)
    end

    def log_error(error, user = nil)
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: error,
        metadata: { user_id: user&.id }
      )
    end
end
