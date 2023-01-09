# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.1'

# RailsAdmin is a Rails engine that provides an easy-to-use interface for managing your data
gem 'rails_admin', '~> 2.2'
gem 'rails_admin_toggleable'

# Support for Penn State Azure Active Directory authentication
gem 'omniauth', '~> 2.0'
gem 'omniauth-oauth2', '~> 1.7'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

gem 'activerecord-import'               # library for bulk inserting data using ActiveRecord
gem 'bootstrap', '< 5.0'
gem 'bugsnag'                           # notify the team of any exceptions
gem 'cancancan', '~> 3.3'               # for authorization
gem 'carrierwave'                       # file uploading
gem 'cocoon'                            # build nested HTML forms
gem 'coffee-rails', '~> 5'              # support for coffeescript
gem 'daemons'                           # for running delayed_job daemon (or other processes)
gem 'ddtrace', '~> 1.4'                 # DataDog APM
gem 'delayed_job_active_record'         # for running async jobs
gem 'devise', '~> 4.8'                  # for authentication and user management
gem 'exiftool_vendored', '~> 12.33'     # ExifTool for parsing PDF metadata
gem 'factory_bot_rails'                 # For generating records in test, development, and staging/beta envs
gem 'ffaker'                            # For generating fake data in test, development, and staging/beta envs
gem 'fieldhand', '~> 0.12'              # harvest metadata from OAI-PMH repositories
gem 'font-awesome-rails'                # UI Icons
gem 'foundation-rails'                  # Foundation for Rails
gem 'httparty'                          # HTTP client
gem 'jbuilder', '~> 2.11'               # build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jquery-rails'                      # jQuery packages for Rails
gem 'jquery-ui-rails'
gem 'jsonapi-serializer'                # a fast JSON:API serializer for Ruby Objects
gem 'multi_json'                        # JSON parser wrapper
gem 'net-imap', require: false          # For Ruby 3 and Rails 6 mail compatibility
gem 'net-ldap'                          # lightweight Directory Access Protocol client
gem 'net-pop', require: false           # For Ruby 3 and Rails 6 mail compatibility
gem 'net-smtp', require: false          # For Ruby 3 and Rails 6 mail compatibility
gem 'net-ssh', '7.0.0.beta1'            # Needed for cap to run with ruby 3.  Can be removed if net-ssh gets updated.
gem 'pdf-reader'                        # Pdf reader
gem 'pg', '>= 0.18', '< 2.0'            # use postgresql as the database for Active Record
gem 'progressbar'                       # the ultimate text progress bar library for Ruby
gem 'psu_identity', '~> 0.2'            # connect to Penn State's identity API
gem 'puma', '~> 5.6'                    # use Puma as the app server
gem 'rss'                               # RSS reading and writing
gem 'sass-rails'                        # sass for stylesheets
gem 'scholarsphere-client', '~> 0.3'    # upload content into ScholarSphere
gem 'simple_form'                       # HTML Form builder
gem 'smarter_csv'                       # simple, efficient CSV processing for Ruby
gem 'strscan', '~> 3.0.5'               # Must be kept at 3.0 to work with bundler 2.3.8
gem 'swagger-blocks'                    # DSL for pure Ruby code blocks that can be turned into JSON
gem 'turbolinks', '~> 5'                # makes navigating your web application faster
gem 'uglifier', '>= 1.3.0'              # use Uglifier as compressor for JavaScript assets
gem 'view_component'                    # Reusable, testable view components
gem 'webpacker'                         # bundle assets

group :development, :test do
  gem 'apivore', git: 'https://github.com/psu-libraries/apivore.git'
  gem 'byebug', platform: :mri
  gem 'niftany'
  gem 'pry-byebug'
end

group :development do
  gem 'bcrypt_pbkdf' # net-ssh requires for ed25519 support
  gem 'capistrano-ext'
  gem 'capistrano-helpers'
  gem 'ed25519'
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', '< 0.18', require: false # CodeClimate does not work with .18 or later
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end
