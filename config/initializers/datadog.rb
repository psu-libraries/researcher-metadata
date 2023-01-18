# frozen_string_literal: true

Datadog.configure do |c|
  c.tracing.instrument :faraday, service_name: 'researcher-metadata-faraday'
  c.tracing.instrument :http, split_by_domain: true
  c.tracing.instrument :pg, service_name: 'researcher-metadata-postgres'
  c.tracing.instrument :rails, service_name: 'researcher-metadata'
  c.tracing.instrument :active_record, service_name: 'researcher-metadata-active-record'
  c.tracing.log_injection = false
  c.tracing.enabled = Settings.datadog.enabled
  c.env = Settings.datadog.env
end
