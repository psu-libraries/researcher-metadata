# Stub out authentication for tests.

# This authentication strategy will automatically succeed for the user that was
# assigned to the `user` class variable.
class StubbedAuthenticationStrategy < ::Devise::Strategies::Base

  # Use this method to set the user that should be authenticated.
  def self.user=(user)
    @@user = user
  end

  # We're a fake authentication strategy; we always succeed.
  def authenticate!
    success! @@user
  end

  # Called if the user doesn't already have a rails session cookie
  def valid?
    true
  end

end

module StubbedAuthenticationHelper

  # Call this method in your "before" block to be signed in as the given user
  # (pass in the entire user object, not just a username).
  def sign_in_as(user)
    StubbedAuthenticationStrategy.user = user
    Warden::Strategies.add :http_header_authenticatable,
                           StubbedAuthenticationStrategy
  end

end

RSpec.configure do |config|

  config.after(:each) do
    Warden::Strategies.add :http_header_authenticatable,
                           Devise::Strategies::HttpHeaderAuthenticatable
    StubbedAuthenticationStrategy.user = nil
  end

  config.include StubbedAuthenticationHelper
end

def authenticate_user
  sign_in_as current_user
end

def authenticate_admin_user
  sign_in_as current_admin_user
end

def current_user
  @current_user ||= create(:user, is_admin: false)
end

def current_admin_user
  @current_admin_user ||= create(:user, is_admin: true)
end
