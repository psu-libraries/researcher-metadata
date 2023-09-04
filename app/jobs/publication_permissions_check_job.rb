# frozen_string_literal: true

class PublicationPermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    permissions = OABPreferredPermissionsService.new(publication.doi_url_path)

    publication.preferred_version = permissions.preferred_version

    publication.save!
  end
end
