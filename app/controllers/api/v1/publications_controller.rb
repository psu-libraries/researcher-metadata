# frozen_string_literal: true

module API::V1
  class PublicationsController < APIController
    def index
      limit = params[:limit].presence || 100

      query = api_token.all_current_publications.visible.limit(limit)

      if params[:activity_insight_id].present?
        query = Publication.filter_by_activity_insight_id(query, params[:activity_insight_id])
      end

      if params[:doi].present?
        query = Publication.filter_by_doi(query, params[:doi])
      end

      render json: API::V1::PublicationSerializer.new(query)
    end

    def show
      @publication = api_token.all_current_publications.visible.find(params[:id])
      render json: API::V1::PublicationSerializer.new(@publication).serializable_hash
    end

    def grants
      publication = api_token.all_current_publications.visible.find(params[:id])
      render json: API::V1::GrantSerializer.new(publication.grants)
    end

    def update_all
      response = ScholarsphereLocationOperator.new(params: params, token: api_token).perform

      render json: { message: I18n.t("api.publications.patch.#{response.message}"), code: response.code },
             status: response.code
    end
  end
end
