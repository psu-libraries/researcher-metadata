# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    # Transaction-based cleanups are fast. But they won't work with Selenium's webdrivers
    # other multi-process situations. So beware of using them in other than completely
    # vanilla setups.
    DatabaseCleaner.strategy = :transaction

    # Now use truncation to start the suite with an empty database.
    DatabaseCleaner.clean_with(:truncation)

    # Make sure all known factories produce #valid? objects.
    FactoryBot.lint

    # Clean up again from the lint check above.
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    # Begin transaction
    DatabaseCleaner.start
  end

  config.after do
    # Roll back transaction
    DatabaseCleaner.clean
  end
end
