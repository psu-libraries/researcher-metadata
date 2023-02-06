# frozen_string_literal: true

class OaWorkflowService
  def workflow
    Publication.needs_doi_verification.each do |pub|
      pub.oa_workflow_state = 'automatic DOI verification pending'
      pub.save!
      DoiVerificationJob.new.perform(pub)
    rescue StandardError
      pub.doi_verified = false
      pub.save!
    end
  end
end
