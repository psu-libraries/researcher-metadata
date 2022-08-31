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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    config.x.scholarsphere = YAML.load_file(Rails.root.join('config/scholarsphere-client.yml'))

    # Using delayed_job for async jobs
    config.active_job.queue_adapter = :delayed_job

    def self.scholarsphere_base_uri
      scholarsphere_api_uri = URI(Rails.application.config.x.scholarsphere['SS4_ENDPOINT'])
      "#{scholarsphere_api_uri.scheme}://#{scholarsphere_api_uri.host}"
    end
  end
end
