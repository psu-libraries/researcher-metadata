# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'ddtrace/auto_instrument'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ResearcherMetadata
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Mail settings
    config.action_mailer.perform_caching = false
    config.action_mailer.perform_deliveries = Settings.action_mailer.perform_deliveries
    config.action_mailer.delivery_method = Settings.action_mailer.delivery_method.to_sym
    config.action_mailer.smtp_settings = { address: Settings.action_mailer.smtp_server, port: Settings.action_mailer.smtp_port }
    config.action_mailer.default_url_options = { protocol: Settings.default_url_options.protocol, host: Settings.default_url_options.host }
    config.action_mailer.raise_delivery_errors = Settings.action_mailer.raise_delivery_errors
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    # Ignore bad email addresses and do not raise email delivery errors.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")


    # Using delayed_job for async jobs
    config.active_job.queue_adapter = :delayed_job

    def self.scholarsphere_base_uri
      scholarsphere_api_uri = URI(Settings.scholarsphere.endpoint)
      "#{scholarsphere_api_uri.scheme}://#{scholarsphere_api_uri.host}"
    end
  end
end
