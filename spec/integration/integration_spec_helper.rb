# frozen_string_literal: true

require 'rails_helper'
require 'support/authentication'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/factory_bot'
require 'support/fixture'
require 'support/mail'
require 'support/fixture'
require 'support/caching_helpers'
require 'support/webdrivers'

RSpec.configure do |config|
  config.include CachingHelpers
end

# Bundle assets if not bundled
unless File.exist?(Rails.root.join('app', 'assets', 'builds', 'bundle.js')) && 
       File.exist?(Rails.root.join('app', 'assets', 'builds', 'bundle.css'))
  require 'rake'
  Rails.application.load_tasks
  Rake::Task['test:prepare'].invoke
end
