# frozen_string_literal: true

class UnpaywallResponse
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def doi
    DOISanitizer.new(json['doi']).url
  end

  def title
    json['title'] || ''
  end

  def matchable_title
    MatchableFormatter.new(title).format
  end

  def is_oa
    json['is_oa']
  end

  def oa_status
    json['oa_status']
  end

  OaLocation = Struct.new(:updated,
                          :url,
                          :url_for_pdf,
                          :url_for_landing_page,
                          :evidence,
                          :license,
                          :version,
                          :host_type,
                          :is_best,
                          :pmh_id,
                          :endpoint_id,
                          :repository_institution,
                          :oa_date)

  def oa_locations
    oals = []
    if json['oa_locations'].present?
      json['oa_locations'].each do |location_data|
        oal = OaLocation.new(location_data['updated'],
                             location_data['url'],
                             location_data['url_for_pdf'],
                             location_data['url_for_landing_page'],
                             location_data['evidence'],
                             location_data['license'],
                             location_data['version'],
                             location_data['host_type'],
                             location_data['is_best'],
                             location_data['pmh_id'],
                             location_data['endpoint_id'],
                             location_data['repository_institution'],
                             location_data['oa_date'])
        oals << oal
      end
    end
    oals
  end

  def oal_urls
    oa_locations.presence ? oa_locations.index_by { |l| l['url'] } : {}
  end

  def oa_locations_embargoed
    json['oa_locations_embargoed']
  end

  def updated
    json['updated']
  end

  def to_s
    json
  end
end
