# frozen_string_literal: true

OkComputer.mount_at = false

OkComputer::Registry.register 'delayed_job_errors', Healthchecks::DelayedJobErrorCheck.new

OkComputer.make_optional %w(delayed_job_errors)
