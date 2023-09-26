# frozen_string_literal: true

class FetchOAMetadataJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    unpaywall_response = UnpaywallClient.query_unpaywall(publication)
    scholarsphere_response = ScholarsphereClient.doi_query(publication)

    if scholarsphere_response.doi_found?
      publication.open_access_locations.find_or_create_by(source: Source::SCHOLARSPHERE, url: scholarsphere_response.url)
    end

    publication.update_from_unpaywall(unpaywall_response)
    publication.oa_status_last_checked_at = Time.zone.now
    publication.oa_workflow_state = nil
    publication.save!
  end
end
