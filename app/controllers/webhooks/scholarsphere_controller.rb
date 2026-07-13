# frozen_string_literal: true

module Webhooks
  class ScholarsphereController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request

    def work_withdrawn
      if params[:publication_url].present?
        locations = OpenAccessLocation.where(source: Source::SCHOLARSPHERE, url: params[:publication_url])
        scholarsphere_work_deposits = ScholarsphereWorkDeposit.where(draft_scholarsphere_work_deposit_url: params[:publication_url],
                                                                     status: ['Success', 'Pending'])

        return head(:not_found) if locations.none? && scholarsphere_work_deposits.none?

        locations.destroy_all
        scholarsphere_work_deposits.destroy_all
        head :no_content
      else
        head :bad_request
      end
    end

    def open_access_work_published
      return head(:bad_request) if params[:scholarsphere_work_url].blank?

      deposit = ScholarsphereWorkDeposit.find_by(draft_scholarsphere_work_deposit_url: params[:scholarsphere_work_url])
      deposit&.record_success(params[:scholarsphere_work_url])
      render plain: 'ok'
    end

    private

      def authenticate_request
        raise 'ScholarSphere webhook secret not configured.' if Settings.scholarsphere.webhook_secret.blank?

        head(:unauthorized) unless request.headers['X-API-KEY'] == Settings.scholarsphere.webhook_secret
      end
  end
end
