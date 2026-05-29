# frozen_string_literal: true

module Webhooks
  class ScholarsphereController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request

    def work_withdrawn
      if params[:publication_url].present?
        locations = OpenAccessLocation.where(source: Source::SCHOLARSPHERE, url: params[:publication_url])
        return head(:not_found) if locations.none?

        locations.destroy_all
        head :no_content
      else
        head :bad_request
      end
    end

    def open_access_work_published
      return head(:bad_request) if params[:scholarsphere_work_url].blank?

      deposit = ScholarsphereWorkDeposit.find_by(draft_scholarsphere_work_deposit_url: params[:scholarsphere_work_url])
      if deposit
        full_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{params[:scholarsphere_work_url]}"
        deposit.record_success(full_url)
      end
      render plain: 'ok'
    end

    private

      def authenticate_request
        raise 'ScholarSphere webhook secret not configured.' if Settings.scholarsphere.webhook_secret.blank?

        head(:unauthorized) unless request.headers['X-API-KEY'] == Settings.scholarsphere.webhook_secret
      end
  end
end
