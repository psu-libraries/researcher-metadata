# frozen_string_literal: true

class PublicationYearSnapshot < ApplicationRecord
  include Statistics

  belongs_to :statistics_snapshot

  rails_admin do
    list do
      field(:created_at)
      field(:year)
      field(:total_article_count)
      field(:open_access_article_count)
      field(:percent_open_access) { label '% open access' }
    end

    show do
      field(:created_at)
      field(:year)
      field(:total_article_count)
      field(:open_access_article_count)
      field(:percent_open_access)
    end
  end
end
