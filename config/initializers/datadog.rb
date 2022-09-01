# frozen_string_literal: true

Rails.configuration.x.datadog = Rails.application.config_for(:datadog)

if Rails.configuration.x.datadog[:enabled]
  require 'ddtrace/auto_instrument'
  Datadog.configure do |c|
    c.tracing.instrument :faraday, service_name: 'researcher-metadata-faraday'
    c.env = Rails.configuration.x.datadog[:env] || 'dev'
  end
end
