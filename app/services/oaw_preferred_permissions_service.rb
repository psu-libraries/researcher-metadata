# frozen_string_literal: true

class OAWPreferredPermissionsService < OAWPermissionsClient
  def initialize(doi)
    super()
    @doi = doi
  end

  def preferred_version
    if permissions.can_deposit_accepted_version? && permissions.can_deposit_published_version?
      Publication::PUBLISHED_OR_ACCEPTED_VERSION
    elsif permissions.can_deposit_published_version?
      I18n.t('file_versions.published_version')
    elsif permissions.can_deposit_accepted_version?
      I18n.t('file_versions.accepted_version')
    else
      Publication::NO_VERSION
    end
  rescue OAWPermissionsSet::PermissionsUnknown
  end

  private

    def permissions
      OAWPermissionsSet.new(all_permissions.map { |p| OAWPermission.new(p) })
    end
end
