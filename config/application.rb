require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV['RAILS_ADMIN_THEME'] = 'material'

module ResearcherMetadata
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

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
