require 'capybara/rspec'
require 'capybara/dsl'

# Put temp files with the rest of the rails files
Capybara.save_path = Pathname.new(File.expand_path(File.dirname(__FILE__) + '/../../tmp'))

RSpec.configure do |config|
  config.include(Capybara::DSL)
end
