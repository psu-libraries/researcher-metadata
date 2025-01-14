# frozen_string_literal: true

class FilePermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOAFile.find(file_id)
    permissions = OABPermissionsService.new(file.doi_url_path, file.version)

    return unless permissions.permissions_found?

    file.license = (permissions.licence.presence || 'https://rightsstatements.org/page/InC/1.0/')
    permissions.set_statement.present? ? file.set_statement = permissions.set_statement : file.checked_for_set_statement = true
    permissions.embargo_end_date.present? ? file.embargo_date = permissions.embargo_end_date : file.checked_for_embargo_date = true
    file.save!
  end
end
