# frozen_string_literal: true

module Healthchecks
  class DelayedJobErrorCheck < OkComputer::Check
    def check
      recent_errors = Delayed::Job.where.not(failed_at: nil).where(failed_at: Settings.delayed_job.failure_threshold_minutes.minutes.ago..).length
      mark_failure if recent_errors.positive?
      mark_message "There have been #{recent_errors} errors within the past #{Settings.delayed_job.failure_threshold_minutes} minutes"
    end
  end
end
