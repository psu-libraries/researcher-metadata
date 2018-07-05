module Devise
  module Strategies
    class HttpHeaderAuthenticatable < ::Devise::Strategies::Base

      include Behaviors::HttpHeaderAuthenticatableBehavior

      # Called if the user doesn't already have a rails session cookie
      def valid?
        valid_user?(request.headers)
      end

      def authenticate!
        user = User.find_by(webaccess_id: webaccess_param)
        if user
          success! user
        else
          fail! "The WebAccess ID or password that you entered is invalid."
        end
      end

      private

      def webaccess_param
        remote_user_access_id(request.headers)
      end

    end
  end
end

Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
