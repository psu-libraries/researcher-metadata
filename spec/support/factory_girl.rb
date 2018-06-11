RSpec.configure do |config|

  # Allow direct use of .build and .create rather than having to say
  # FactoryGirl.build and FactoryGirl.create.
  config.include FactoryGirl::Syntax::Methods

end
