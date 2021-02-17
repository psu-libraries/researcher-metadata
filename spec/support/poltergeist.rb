require 'capybara/poltergeist'
require_relative '../../spec/support/poltergeist_helpers'

# We'll use the Rack::Test driver by default, and poltergeist for tests
# that have been tagged for javascript.

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.javascript_driver = :poltergeist
