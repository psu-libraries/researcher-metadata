# frozen_string_literal: true

class ActivityInsightOADashboardComponent < ViewComponent::Base
  def doi_failed_verification_count
    Publication.doi_failed_verification.count
  end

  def file_version_check_failed_count
    Publication.file_version_check_failed.count
  end

  def permissions_check_failed_count
    Publication.permissions_check_failed.count
  end

  def ready_for_metadata_review_count
    Publication.ready_for_metadata_review.count
  end

  def i18n(key, **options)
    I18n.t("view_component.#{self.class.name.underscore}.#{key}", **options)
  end
end
