# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class AzureOauth < OmniAuth::Strategies::OAuth2
      option :name, :azure_oauth

      option :authorize_params,
             domain_hint: 'psu.edu'

      option :client_options,
             site: Rails.configuration.x.azure_ad_oauth['oauth_app_url'],
             token_url: Rails.configuration.x.azure_ad_oauth['oauth_token_url'],
             authorize_url: Rails.configuration.x.azure_ad_oauth['oauth_authorize_url']

      uid do
        raw_info['upn'].split('@')[0]
      end

      # Override callback URL. OmniAuth by default passes the entire URL of the callback, including query
      # parameters. Azure fails validation because that doesn't match the registered callback.
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end

      private
      
      def raw_info
        @raw_info ||= JSON.parse(Base64.decode64(access_token['id_token'].split('.')[1]))
      end
    end
  end
end
