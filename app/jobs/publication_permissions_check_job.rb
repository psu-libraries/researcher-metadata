# frozen_string_literal: true

class PublicationPermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    permissions = OAWPreferredPermissionsService.new(publication.doi_url_path)

    publication.update!(preferred_version: permissions.preferred_version)
  end
end
