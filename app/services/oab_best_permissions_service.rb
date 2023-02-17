# frozen_string_literal: true

class OabBestPermissionsService < OabPermissionsClient
  def initialize(doi)
    super()
    @doi = doi
    @permissions = all_permissions
  end

  def best_permission
    JSON.parse(permissions_response)['best_permission']
  rescue JSON::ParserError
    nil
  end

  def best_version
    best_permission['version']
  end

  def set_statement
    best_permission['deposit_statement'].presence
  end

  def embargo_end_date
    if best_permission['embargo_end'].present?
      Date.parse(best_permission['embargo_end'], '%Y-%m-%d')
    end
  end

  def licence
    LicenceMapper.map(best_permission['licence'].presence)
  end
end
