# frozen_string_literal: true

require 'rails_helper'
require 'support/authentication'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/factory_bot'
require 'support/fixture'
require 'support/mail'
require 'support/fixture'

# Prepare assets for integration tests
require 'rake'
Rails.application.load_tasks
Rake::Task['test:prepare'].invoke
