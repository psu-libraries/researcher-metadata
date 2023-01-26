# frozen_string_literal: true

class ActivityInsightOaDashboardComponent < ViewComponent::Base
  def doi_unverified_count
    Publication.doi_unverified.count
  end

  def i18n(key, **options)
    I18n.t("view_component.#{self.class.name.underscore}.#{key}", **options)
  end
end
