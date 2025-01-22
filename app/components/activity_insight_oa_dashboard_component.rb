# frozen_string_literal: true

class ActivityInsightOADashboardComponent < ViewComponent::Base
  def doi_failed_verification_count
    Publication.doi_failed_verification.count
  end

  def file_version_check_failed_count
    Publication.file_version_check_failed.count
  end

  def wrong_file_version_count
    Publication.wrong_file_version.count
  end

  def wrong_version_author_notified_count
    Publication.wrong_version_author_notified.count
  end

  def preferred_file_version_none_count
    Publication.preferred_file_version_none.count
  end

  def needs_manual_preferred_version_check_count
    Publication.needs_manual_preferred_version_check.count
  end

  def needs_manual_permissions_review_count
    Publication.needs_manual_permissions_review.count
  end

  def ready_for_metadata_review_count
    Publication.ready_for_metadata_review.count
  end

  def flagged_for_review_count
    Publication.flagged_for_review.count
  end

  def all_workflow_publications_count
    Publication.troubleshooting_list.count
  end
end
