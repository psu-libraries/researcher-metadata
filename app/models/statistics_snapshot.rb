class StatisticsSnapshot < ApplicationRecord

  def self.record
    create(total_article_count: Publication.journal_article.count,
           open_access_article_count: Publication.journal_article.open_access.count)
  end

  def percent_open_access
    ((open_access_article_count.to_f / total_article_count) * 100).round 1
  end

  rails_admin do
    list do
      field(:created_at)
      field(:total_article_count)
      field(:open_access_article_count)
      field(:percent_open_access) { label '% open access' }
    end

    show do
      field(:created_at)
      field(:total_article_count)
      field(:open_access_article_count)
      field(:percent_open_access)
    end
  end
end
