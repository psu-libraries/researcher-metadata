# frozen_string_literal: true

module API::V1
  class OrganizationsController < APIController
    def index
      render json: API::V1::OrganizationSerializer.new(api_token.all_organizations.visible)
    end

    def publications
      org = api_token.all_organizations.visible.find(params[:id])
      render json: API::V1::PublicationSerializer.new(org.all_publications
                                                         .offset(params[:offset])
                                                         .limit(params[:limit]))
    end
  end
end
