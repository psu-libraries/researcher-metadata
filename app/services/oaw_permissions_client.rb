# frozen_string_literal: true

class OAWPermissionsClient
  class InvalidVersion < StandardError; end
  attr_reader :doi, :version

  VALID_VERSIONS = [I18n.t('file_versions.accepted_version'),
                    I18n.t('file_versions.published_version')].freeze

  private

    def all_permissions
      @all_permissions ||= JSON.parse(permissions_response)['all_permissions']
    rescue JSON::ParserError
      nil
    end

    def permissions_response
      HttpService.get(oaw_permissions_w_doi_url)
    rescue Net::ReadTimeout, Net::OpenTimeout
      ''
    end

    def oaw_permissions_w_doi_url
      oaw_permissions_base_url + CGI.escape(doi.to_s)
    end

    def oaw_permissions_base_url
      'https://bg.api.oa.works/permissions/'
    end

    def accepted_version
      if all_permissions.present?
        all_permissions
          .select { |perm| perm if perm['version'] == I18n.t('file_versions.accepted_version') }
          .first
          .presence || {}
      else
        {}
      end
    end

    def published_version
      if all_permissions.present?
        all_permissions
          .select { |perm| perm if perm['version'] == I18n.t('file_versions.published_version') }
          .first
          .presence || {}
      else
        {}
      end
    end
end
