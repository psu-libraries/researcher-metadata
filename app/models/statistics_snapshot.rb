# frozen_string_literal: true

class StatisticsSnapshot < ApplicationRecord
  include Statistics

  has_many :publication_year_snapshots

  def self.record
    @oa_publication = Publication.oa_publication
    snapshot = create(total_article_count: @oa_publication.count,
                      open_access_article_count: @oa_publication.open_access.count)
    range = 2019..DateTime.now.year
    range.each do |year|
      articles = @oa_publication.where(published_on: DateTime.new(year).all_year)
      if articles.present?
        snapshot.publication_year_snapshots.create(
          publication_year: year,
          total_article_count: articles.count,
          open_access_article_count: articles.open_access.count
        )
      end
    end
    snapshot
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
      field(:publication_year_snapshots)
    end
  end
end
