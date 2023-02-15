# frozen_string_literal: true

class OaWorkflowService
  def workflow
    Publication.needs_doi_verification.each do |pub|
      pub.oa_workflow_state = 'automatic DOI verification pending'
      pub.save!
      DoiVerificationJob.perform_later(pub.id)
    rescue StandardError
      pub.update_column(:doi_verified, false)
      raise
    end

    Publication.needs_oa_metadata_search.each do |pub|
      pub.oa_workflow_state = 'oa metadata search pending'
      pub.save!
      FetchOAMetadataJob.new.perform(pub)
    rescue StandardError
      pub.update_column(:oa_workflow_state, 'error during oa metadata search')
      raise
    end
  end
end
