# frozen_string_literal: true

class OABPreferredPermissionsService < OABPermissionsClient
  def initialize(doi)
    super()
    @doi = doi
    @permissions = all_permissions
  end

  def preferred_permission
    accepted = false
    published = false

    all_permissions.each do |perm|
      accepted = true if perm['version'] == I18n.t('file_versions.accepted_version') && perm['can_archive'] == true && perm['locations'].map(&:downcase).include?('institutional repository')
      published = true if perm['version'] == I18n.t('file_versions.published_version') && perm['can_archive'] == true && perm['locations'].map(&:downcase).include?('institutional repository')
    end

    if accepted && !published
      accepted_version
    elsif published
      published_version
    else
      {}
    end
  end

  def preferred_version
    preferred_permission['version']
  end

  def set_statement
    preferred_permission['deposit_statement'].presence
  end

  def embargo_end_date
    if preferred_permission['embargo_end'].present?
      Date.parse(preferred_permission['embargo_end'], '%Y-%m-%d')
    end
  end

  def licence
    LicenceMapper.map(preferred_permission['licence'].presence)
  end
end
