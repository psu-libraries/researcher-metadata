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
          if URI.parse(request.url).path == Rails.application.routes.url_helpers.new_external_publication_waiver_path ||
            URI.parse(request.url).path == Rails.application.routes.url_helpers.edit_profile_publications_path

            redirect!("https://sites.psu.edu/openaccess/waiver-form/")
          else
            redirect!(Rails.application.routes.url_helpers.root_path)
          end
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
