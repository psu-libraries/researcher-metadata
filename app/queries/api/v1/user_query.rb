module API::V1
  class UserQuery

    def initialize(user)
      @user = user
    end

    attr_reader :user

    def presentations(params={})
      user.presentations.visible
    end

    def news_feed_items(params={})
      user.news_feed_items
    end

    def performances(params={})
      user.performances.visible
    end

    def etds(params={})
      user.etds
    end

    def publications(params={})
      if user.show_all_publications
        if params[:start_year] && params[:end_year]
          starts_on = Date.new(params[:start_year].to_i)
          ends_on = Date.new(params[:end_year].to_i).end_of_year
          data = user.publications.visible.where(published_on: starts_on..ends_on)
        else
          data = user.confirmed_publications.visible
        end

        if params[:order_first_by].present?
          case params[:order_first_by]
          when 'citation_count_desc' then data = data.order('total_scopus_citations DESC NULLS LAST')
          when 'publication_date_desc' then data = data.order(published_on: :desc)
          when 'publication_date_asc' then data = data.order(published_on: :asc)
          when 'title_asc' then data = data.order(title: :asc)
          end
        end

        if params[:order_second_by].present?
          case params[:order_second_by]
          when 'citation_count_desc' then data = data.order('total_scopus_citations DESC NULLS LAST')
          when 'publication_date_desc' then data = data.order(published_on: :desc)
          when 'publication_date_asc' then data = data.order(published_on: :asc)
          when 'title_asc' then data = data.order(title: :asc)
          end
        end

        params[:limit].present? ? limit = params[:limit] : limit = 100
        data = data.limit(limit)

        data
      else
        Publication.none
      end
    end
  end
end
