# frozen_string_literal: true

class ActivityInsightOaDashboardComponent < ViewComponent::Base
  def doi_unverified_count
    Publication.doi_unverified.count
  end
end
