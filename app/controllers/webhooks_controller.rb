# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request

  def scholarsphere_events
    if params[:publication_url].present?
      locations = OpenAccessLocation.where(source: Source::SCHOLARSPHERE, url: params[:publication_url])
      return head(:not_found) if locations.none?

      locations.destroy_all
      head :no_content
    else
      head :bad_request
    end
  end

  private

    def authenticate_request
      raise 'ScholarSphere webhook secret not configured.' if Settings.scholarsphere.webhook_secret.blank?

      head(:unauthorized) unless request.headers['X-API-KEY'] == Settings.scholarsphere.webhook_secret
    end
end
