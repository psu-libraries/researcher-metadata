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
      field(:publication_year_snapshots) do
        pretty_value do
          view = bindings[:view]
          snapshots = bindings[:object]
            .publication_year_snapshots
            .order(:publication_year)

          attributes = %i[
            publication_year
            total_article_count
            open_access_article_count
            percent_open_access
          ]

          headers = attributes.map do |attribute|
            PublicationYearSnapshot.human_attribute_name(attribute).titleize
          end

          thead = view.content_tag(:thead) do
            view.content_tag(:tr) do
              view.safe_join(headers.map { |header| view.content_tag(:th, header) })
            end
          end

          tbody = view.content_tag(:tbody) do
            rows = snapshots.map do |snapshot|
              year_path = view.rails_admin.show_path(
                model_name: 'PublicationYearSnapshot',
                id: snapshot.id
              )

              cells = [
                view.link_to(snapshot.publication_year, year_path),
                snapshot.total_article_count,
                snapshot.open_access_article_count,
                snapshot.percent_open_access.nil? ? '—' : "#{snapshot.percent_open_access}%"
              ]

              view.content_tag(:tr) do
                view.safe_join(cells.map { |cell| view.content_tag(:td, cell) })
              end
            end

            view.safe_join(rows)
          end

          view.content_tag(:table, class: 'table') do
            view.safe_join([thead, tbody])
          end
        end
      end
    end
  end
end
