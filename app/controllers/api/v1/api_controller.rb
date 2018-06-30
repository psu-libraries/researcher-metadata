module API::V1
  class APIController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: exception, status: 404
    end
  end
end
