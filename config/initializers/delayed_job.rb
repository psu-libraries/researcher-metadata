# frozen_string_literal: true

Delayed::Worker.max_attempts = 1
Delayed::Worker.destroy_failed_jobs = false

if Rails.env.test?
  Delayed::Worker.delay_jobs = false
end
