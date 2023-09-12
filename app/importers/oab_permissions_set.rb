# frozen_string_literal: true

class OABPermissionsSet
  def initialize(permissions)
    @permissions = permissions
  end

  def can_deposit_accepted_version?
    can_deposit?(I18n.t('file_versions.accepted_version'))
  end

  def can_deposit_published_version?
    can_deposit?(I18n.t('file_versions.published_version'))
  end

  private

    attr_accessor :permissions

    def can_deposit?(version)
      permissions.find do |p|
        p.version == version && p.can_archive_in_institutional_repository? && !p.has_requirements?
      end.present?
    end
end
