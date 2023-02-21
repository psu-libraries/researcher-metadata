# frozen_string_literal: true

class OABPermissionsClient
  class InvalidVersion < StandardError; end
  attr_reader :doi, :version, :permissions

  VALID_VERSIONS = [I18n.t('file_versions.accepted_version'),
                    I18n.t('file_versions.published_version')].freeze

  private

    def all_permissions
      JSON.parse(permissions_response)['all_permissions']
    rescue JSON::ParserError
      nil
    end

    def permissions_response
      HttpService.get(oab_permissions_w_doi_url)
    rescue Net::ReadTimeout, Net::OpenTimeout
      ''
    end

    def oab_permissions_w_doi_url
      oab_permissions_base_url + CGI.escape(doi.to_s)
    end

    def oab_permissions_base_url
      'https://api.openaccessbutton.org/permissions/'
    end

    def accepted_version
      if permissions.present?
        permissions
          .select { |perm| perm if perm['version'] == I18n.t('file_versions.accepted_version') }
          .first
          .presence || {}
      else
        {}
      end
    end

    def published_version
      if permissions.present?
        permissions
          .select { |perm| perm if perm['version'] == I18n.t('file_versions.published_version') }
          .first
          .presence || {}
      else
        {}
      end
    end
end
