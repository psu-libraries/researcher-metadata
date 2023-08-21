# frozen_string_literal: true

class FetchOAMetadataJob < ApplicationJob
  queue_as 'default'

  def perform(publication_id)
    publication = Publication.find(publication_id)
    unpaywall_response = UnpaywallClient.query_unpaywall(publication)
    oab_response = OABClient.query_open_access_button(publication)

    if unpaywall_response.oa_locations.present?
      publication.update_from_unpaywall(unpaywall_response)
    elsif oab_response.url
      publication.open_access_locations.create!(source: Source::OPEN_ACCESS_BUTTON, url: oab_response.url)
      publication.open_access_button_last_checked_at = Time.zone.now
    end

    publication.oa_status_last_checked_at = Time.zone.now
    publication.oa_workflow_state = nil
    publication.save!
  end
end
