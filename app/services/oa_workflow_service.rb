# frozen_string_literal: true

class OaWorkflowService
  def workflow
    Publication.needs_doi_verification.each do |pub|
      pub.oa_workflow_state = 'automatic DOI verification pending'
      pub.save!
      DoiVerificationJob.perform_later(pub.id)
    rescue StandardError
      pub.doi_verified = false
      pub.save!
      raise
    end

    ActivityInsightOaFile.needs_permissions_check.each do |file|
      file.version_checked = true
      file.save!
      PermissionsCheckJob.perform_later(file.id)
    rescue StandardError
      file.update_column(:version_checked, true)
      raise
    end
  end
end
