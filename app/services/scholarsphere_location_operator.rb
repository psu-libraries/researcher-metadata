# frozen_string_literal: true

class ScholarsphereLocationOperator
  def initialize(params:, token:)
    @params = params
    @token = token
  end

  def perform
    if !@token.write_access?
      operator_response(401, 'unauthorized')
    elsif !params_valid?
      invalid_params_response
    elsif update_open_access_location.present?
      operator_response(200, 'success')
    elsif @existing_location
      operator_response(422, 'existing_location')
    else
      operator_response(404, 'no_content')
    end
  end

  private

    attr_reader :params, :token

    def params_valid?
      return false if params[:scholarsphere_open_access_url].blank?

      params[:activity_insight_id].present? ^ params[:doi].present?
    end

    def invalid_params_response
      if params[:scholarsphere_open_access_url].blank?
        operator_response(422, 'params_missing_url')
      elsif params[:activity_insight_id].blank? && params[:doi].blank?
        operator_response(422, 'params_missing_id')
      elsif params[:activity_insight_id].present? && params[:doi].present?
        operator_response(422, 'params_both_ids')
      else
        operator_response(422, 'params_invalid')
      end
    end

    def update_open_access_location
      locations = []

      ActiveRecord::Base.transaction do
        filtered_publications.each do |publication|
          return if existing_location?(publication)

          location = find_or_create_location(publication)
          locations << location.url if location.valid?
        end
      end

      locations
    end

    def filtered_publications
      publications = []

      if params[:activity_insight_id].present?
        publications = Publication.filter_by_activity_insight_id(Publication, params[:activity_insight_id])
      elsif params[:doi].present?
        publications = Publication.filter_by_doi(Publication, params[:doi])
      end

      publications
    end

    def existing_location?(publication)
      @existing_location ||= publication.open_access_locations
        .filter { |l| l.source == Source::SCHOLARSPHERE }
        .index_by(&:url)
        .key?(params[:scholarsphere_open_access_url])
    end

    def find_or_create_location(publication)
      publication.open_access_locations.find_or_create_by(
        source: Source::SCHOLARSPHERE,
        url: params[:scholarsphere_open_access_url]
      )
    end

    def operator_response(code, message)
      OpenStruct.new(code: code, message: message)
    end
end
