require 'database_cleaner'

RSpec.configure do |config|

  config.before(:suite) do

    # Transaction-based cleanups are fast. But they won't work with poltergeist or
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

  config.before(:each) do
    # Begin transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    # Roll back transaction
    DatabaseCleaner.clean
  end

end
