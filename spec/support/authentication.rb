# frozen_string_literal: true

module StubbedAuthenticationHelper
  # Call this method in your "before" block to be signed in as the given user
  # (pass in the entire user object, not just a username).

  def sign_in_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:azure_oauth] = OmniAuth::AuthHash.new({
                                                                       provider: 'azure_oauth',
                                                                       uid: user.webaccess_id
                                                                     })
  end
end

RSpec.configure do |config|
  config.after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:azure_oauth] = nil
  end

  config.include StubbedAuthenticationHelper
end

def authenticate_as(user)
  sign_in_as user
  visit root_path
  click_on 'Sign in'
end

def impersonate_user(primary:, deputy:)
  authenticate_as(deputy)
  visit profile_path(webaccess_id: primary.webaccess_id)
  click_link('Become this user')
end

def authenticate_user
  sign_in_as current_user
  visit root_path
  click_on 'Sign in'
end

def authenticate_admin_user
  sign_in_as current_admin_user
  visit root_path
  click_on 'Sign in'
end

def current_user
  @current_user ||= create(:user, is_admin: false)
end

def current_admin_user
  @current_admin_user ||= create(:user, is_admin: true)
end
