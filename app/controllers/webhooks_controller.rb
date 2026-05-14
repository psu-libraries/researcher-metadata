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

  def open_access_works
    # The scholarsphere_work_url param contains the relative path e.g. "/resources/{uuid}"
    # sent by ScholarSphere when a deposit finishes publishing.
    # If it's missing, we still return 'ok' — ScholarSphere expects a success response regardless.
    if params[:scholarsphere_work_url].present?

      # Find the deposit that was originally submitted with this draft URL.
      # The draft_scholarsphere_work_deposit_url was stored on the record when the
      # deposit was first sent to ScholarSphere, before it was fully published.
      deposit = ScholarsphereWorkDeposit.find_by(draft_scholarsphere_work_deposit_url: params[:scholarsphere_work_url])

      if deposit
        # Build the full URL by prepending the ScholarSphere base URI (e.g. "https://scholarsphere.psu.edu")
        # to the relative path. This matches how ScholarsphereDepositService and ScholarsphereImporter
        # construct ScholarSphere URLs elsewhere in the app.
        full_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}#{params[:scholarsphere_work_url]}"

        # record_success marks the deposit as 'Success', sets deposited_at,
        # creates/updates the OpenAccessLocation with source SCHOLARSPHERE,
        # and destroys the associated file uploads.
        deposit.record_success(full_url)
      end
      # If no matching deposit is found, we silently no-op — per the ticket,
      # a success response is returned either way.
    end

    render plain: 'ok'
  end

  private

    def authenticate_request
      raise 'ScholarSphere webhook secret not configured.' if Settings.scholarsphere.webhook_secret.blank?

      head(:unauthorized) unless request.headers['X-API-KEY'] == Settings.scholarsphere.webhook_secret
    end
end
