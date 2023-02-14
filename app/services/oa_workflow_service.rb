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
      raise
    end

    Publication.needs_permissions_check.each do |pub|
      pub.oa_workflow_state = 'automatic permissions check pending'
      pub.save!
      PermissionsCheckJob.new.perform(pub)
    rescue StandardError
      pub.update_column(:oa_workflow_state, 'error during permissions check')
      raise
    end
  end
end
