require 'devise/behaviors/http_header_authenticatable_behavior'
require 'devise/strategies/http_header_authenticatable'

module Devise
  module Models
    module HttpHeaderAuthenticatable
      extend ActiveSupport::Concern

      def after_database_authentication
      end
    end
  end
end
