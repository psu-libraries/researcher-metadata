# frozen_string_literal: true

class OabPermissionsService
  class InvalidVersion < StandardError; end
  attr_reader :doi, :version

  VALID_VERSIONS = ['acceptedVersion', 'publishedVersion'].freeze

  def initialize(doi, version)
    raise InvalidVersion if VALID_VERSIONS.exclude?(version)

    @doi = doi
    @version = version
  end

  def set_statement
    this_versions_perms['deposit_statement'].presence
  end

  def embargo_end_date
    this_versions_perms['embargo_end'].present? ? Date.parse(this_versions_perms['embargo_end'], '%Y-%m-%d') : nil
  end

  def licence
    this_versions_perms['licence'].presence
  end

  private

    def this_versions_perms
      if all_permissions.present?
        all_permissions.map { |perm| perm if perm['version'] == version }.first.presence || {}
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
