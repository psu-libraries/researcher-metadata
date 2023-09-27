# frozen_string_literal: true

class OAWorkflowService
  def workflow
    Publication.needs_doi_verification.each do |pub|
      pub.oa_workflow_state = 'automatic DOI verification pending'
      pub.save!
      DOIVerificationJob.perform_later(pub.id)
    rescue StandardError
      pub.update_column(:doi_verified, false)
      raise
    end

    Publication.needs_oa_metadata_search.each do |pub|
      pub.oa_workflow_state = 'oa metadata search pending'
      pub.save!
      FetchOAMetadataJob.perform_later(pub.id)
    end

    Publication.needs_permissions_check.each do |pub|
      pub.permissions_last_checked_at = Time.current
      pub.save!
      PermissionsCheckJob.perform_later(pub.id)
    rescue StandardError
      pub.update_column(:permissions_last_checked_at, Time.current)
      raise
    end

    ActivityInsightOAFile.ready_for_download.each do |file|
      file.downloaded = true
      file.save!
      PublicationDownloadJob.perform_later(file.id)
    rescue StandardError
      file.update_column(:downloaded, false)
    end

    ActivityInsightOAFile.send_oa_status_to_activity_insight.each do |file|
      file.exported_oa_status_to_activity_insight = true
      file.save!
      AiOAStatusExportJob.perform_later(file.id)
    end
  end
end
