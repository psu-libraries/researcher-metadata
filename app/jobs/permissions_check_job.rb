# frozen_string_literal: true

class PermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOAFile.find(file_id)
    publication = file.publication
    permissions = OABPreferredPermissionsService.new(publication.doi_url_path)
    publication.preferred_version = permissions.preferred_version

    if permissions.preferred_version == file.version
      publication.set_statement = permissions.set_statement
      publication.licence = permissions.licence
      publication.embargo_date = permissions.embargo_end_date
    end

    publication.permissions_last_checked_at = Time.current
    publication.save!
  end
end
