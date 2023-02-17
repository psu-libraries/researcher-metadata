# frozen_string_literal: true

class PermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOaFile.find(file_id)
    publication = Publication.find(file.publication_id)
    permissions = OabBestPermissionsService.new(publication.doi_url_path)
    publication.preferred_version = permissions.best_version

    if permissions.best_version == file.version
      publication.set_statement = permissions.set_statement
      publication.licence = permissions.licence
      publication.embargo_date = permissions.embargo_end_date
    end

    publication.permissions_last_checked_at = Time.current
    publication.save!
  end
end
