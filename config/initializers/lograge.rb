# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = Settings.lograge.enabled
  config.lograge.formatter = Lograge::Formatters::Json.new if Settings.lograge.json
  config.lograge.custom_payload do |controller|
    {
      request_id: controller.request.env['action_dispatch.request_id']
    }
  end

  config.lograge.custom_options = lambda do |event|
    {
      remote_addr: event.payload[:headers][:REMOTE_ADDR],
      x_forwarded_for: event.payload[:headers][:HTTP_X_FORWARDED_FOR]
    }
  end
end
