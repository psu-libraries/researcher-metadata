require 'bundler/capistrano'            # Use bundler on remote server
require 'capistrano/ext/multistage'     # Support for multiple deploy targets
require 'capistrano-helpers/branch'     # Ask user what tag to deploy
require 'capistrano-helpers/passenger'  # Support for Apache passenger
require 'capistrano-helpers/git'        # Support for git
require 'capistrano-helpers/shared'     # Symlink shared files after deploying
require 'capistrano-helpers/migrations' # Run all migrations automatically
require 'capistrano-helpers/robots'     # Keep robots out of staging and beta

# Location of the source code.
set :repository,  'git@github.com:psu-stewardship/researcher-metadata.git'

# The remote user to log in as.
set :user, 'deploy'

# Our setup does not require or allow sudo.
set :use_sudo, false

# PSU server uses non-standard SSH port
ssh_options[:port] = 1855

# Set the files that should be replaced with their private counterparts.
set :shared, %w{
  config/database.yml
  config/secrets.yml
  config/activity_insight.yml
  config/orcid.yml
  config/pure.yml
  db/data
}

# The directory that we're deploying to on the remote host.
set :deploy_to, "/var/www/sites/metadata"

# Delayed Job hook
after 'deploy:restart', 'delayed_job:restart'
namespace :delayed_job do
  task :restart do
    run "cd #{deploy_to}/current && bin/delayed_job restart"
  end
end
