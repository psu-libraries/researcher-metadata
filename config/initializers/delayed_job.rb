# frozen_string_literal: true

Delayed::Worker.max_attempts = 1
Delayed::Worker.destroy_failed_jobs = false

# Sinatra 4.x / rack-protection 4.x adds a strict HostAuthorization middleware that
# by default only allows localhost. We must explicitly permit the app's host per
# environment. Rails' ActionDispatch::HostAuthorization already protects the app at
# the outer Rack layer; this just satisfies the inner Sinatra check.
permitted = [Settings.default_url_options.host]
permitted << 'www.example.com' if Rails.env.test? # Rails request spec default host
DelayedJobWeb.set :host_authorization, { permitted_hosts: permitted }

if Rails.env.test?
  Delayed::Worker.delay_jobs = false
end
