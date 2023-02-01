# frozen_string_literal: true

class ActivityInsightOaDashboardComponent < ViewComponent::Base
  def doi_failed_verification_count
    Publication.doi_failed_verification.count
  end

  def i18n(key, **options)
    I18n.t("view_component.#{self.class.name.underscore}.#{key}", **options)
  end
end
