module Devise
  module Behaviors
    module HttpHeaderAuthenticatableBehavior

      # Called if the user doesn't already have a rails session cookie
      def valid_user?(headers)
        remote_user_access_id(headers).present?
      end

      protected

      def remote_user_access_id(headers)
        return headers['REMOTE_USER'] if headers['REMOTE_USER']
        return headers['HTTP_REMOTE_USER'] if headers['HTTP_REMOTE_USER'] && Rails.env.development?
        return nil
      end

    end
  end
end
