# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 5.5'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Notify the team of any exceptions
gem 'bugsnag'

# Simple, efficient CSV processing for Ruby
gem 'smarter_csv'

# Library for bulk inserting data using ActiveRecord
gem 'activerecord-import'

# The ultimate text progress bar library for Ruby
gem 'progressbar'

# RailsAdmin is a Rails engine that provides an easy-to-use interface for managing your data
gem 'rails_admin', '~> 1.4'

gem 'rails_admin_toggleable'

# Authentication framework
gem 'devise', '~> 4.8'

# Support for Penn State Azure Active Directory authentication
gem 'omniauth', '~> 2.0'
gem 'omniauth-oauth2', '~> 1.7'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

# Authorization framework
gem 'cancancan', '~> 2.0'

# A lightning fast JSON:API serializer for Ruby Objects
gem 'fast_jsonapi'

# Swagger::Blocks is a DSL for pure Ruby code blocks that can be turned into JSON
gem 'swagger-blocks'

# Include swagger-ui as a Raile engine
gem 'swagger_ui_engine'

# A Material Design theme for rails_admin
gem 'rails_admin_material'

# Bootstrap 4 ruby gem for Ruby on Rails
gem 'bootstrap', '< 5.0'

# jQuery for Rails
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Foundation for Rails
gem 'foundation-rails'

# HTTP client
gem 'httparty'

# UI Icons
gem 'font-awesome-rails'

# Lightweight Directory Access Protocol client
gem 'net-ldap'

# JSON parser wrapper
gem 'multi_json'

# HTML Form builder
gem 'simple_form'

# Build nested HTML forms
gem 'cocoon'

# Harvest metadata from OAI-PMH repositories
gem 'fieldhand', '~> 0.12'

# ScholarSphere API HTTP client for depositing works on behalf of users
gem 'scholarsphere-client', '~> 0.3'

# File uploading
gem 'carrierwave'

# For running async jobs
gem 'delayed_job_active_record'

# For running delayed_job daemon (or other processes)
gem 'daemons'

gem 'psu_identity', github: 'psu-libraries/psu_identity', branch: 'main'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Enables binding.pry for debugging
  gem 'pry-byebug'

  # Default test framework
  gem 'rspec-rails'

  # Generate fake test data
  gem 'ffaker'

  # Automatically test your rails API against its OpenAPI (Swagger) description
  # of end-points, models, and query parameters
  gem 'apivore'

  gem 'niftany'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Deploy to multiple environments
  gem 'capistrano-ext'

  # Useful recipes for generalizing deployment behavior
  gem 'capistrano-helpers'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', '< 0.18', require: false # CodeClimate does not work with .18 or later
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end
