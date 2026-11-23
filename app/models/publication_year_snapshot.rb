# frozen_string_literal: true

class PublicationYearSnapshot < ApplicationRecord
  include Statistics

  belongs_to :statistics_snapshot

  def admin_label
    publication_year.to_s
  end

  rails_admin do
    show do
      field(:created_at)
      field(:publication_year)
      field(:total_article_count)
      field(:open_access_article_count)
      field(:percent_open_access)
    end
  end
end
