RSpec.configure do |config|

  # Allow direct use of .build and .create rather than having to say
  # FactoryBot.build and FactoryBot.create.
  config.include FactoryBot::Syntax::Methods

end
