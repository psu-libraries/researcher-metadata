# frozen_string_literal: true

class ActivityInsightOaDashboardComponent < ViewComponent::Base
  def needs_doi_check_count
    Publication.needs_doi_checked.count
  end
end
