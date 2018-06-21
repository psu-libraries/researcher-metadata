module API::V1
  class PublicationsController < APIController
    def index
      render json: API::V1::PublicationSerializer.new(Publication.all).serialized_json
    end

    def show
      @publication = Publication.find(params[:id])
      render json: API::V1::PublicationSerializer.new(@publication).serializable_hash
    end
  end
end
