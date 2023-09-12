# frozen_string_literal: true

class OABPreferredPermissionsService < OABPermissionsClient
  def initialize(doi)
    super()
    @doi = doi
  end

  def preferred_version
    if permissions.can_deposit_accepted_version? && permissions.can_deposit_published_version?
      'Published or Accepted'
    elsif permissions.can_deposit_published_version?
      I18n.t('file_versions.published_version')
    elsif permissions.can_deposit_accepted_version?
      I18n.t('file_versions.accepted_version')
    end
  end

  private

    def permissions
      OABPermissionsSet.new(all_permissions.map { |p| OABPermission.new(p) })
    end
end
