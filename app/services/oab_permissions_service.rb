# frozen_string_literal: true

class OabPermissionsService
  class InvalidVersion < StandardError; end
  attr_reader :doi, :version, :permissions

  ACCEPTED_VERSION = 'acceptedVersion'
  PUBLISHED_VERSION = 'publishedVersion'
  VALID_VERSIONS = [ACCEPTED_VERSION, PUBLISHED_VERSION].freeze

  def initialize(doi, version)
    raise InvalidVersion if VALID_VERSIONS.exclude?(version)

    @doi = doi
    @version = version
    @permissions = all_permissions
  end

  def set_statement
    this_version['deposit_statement'].presence
  end

  def embargo_end_date
    if this_version['embargo_end'].present?
      Date.parse(this_version['embargo_end'], '%Y-%m-%d')
    end
  end

  def licence
    LicenceMapper.map(this_version['licence'].presence)
  end

  def other_version_preferred?
    return false if this_version.present?

    return true if accepted_version.present? || published_version.present?

    false
  end

  def this_version
    return accepted_version if accepted_version['version'] == version

    return published_version if published_version['version'] == version

    {}
  end

  private

    def accepted_version
      if permissions.present?
        permissions.map { |perm| perm if perm['version'] == ACCEPTED_VERSION }.first.presence || {}
      else
        {}
      end
    end

    def published_version
      if permissions.present?
        permissions.map { |perm| perm if perm['version'] == PUBLISHED_VERSION }.first.presence || {}
      else
        {}
      end
    end

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
end
