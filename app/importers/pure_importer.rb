# frozen_string_literal: true

class PureImporter
  class ServiceNotFound < RuntimeError; end

  private

    def api_version
      '520'
    end

    def base_url
      "https://pennstate.pure.elsevier.com/ws/api/#{api_version}"
    end

    def pure_api_key
      Rails.configuration.x.pure['api_key']
    end

    def total_records
      response = get_records(type: record_type, page_size: 1, offset: 0)
      if response['status'] == 404
        raise ServiceNotFound.new("The requested Pure API endpoint was not found. The version #{api_version} may no longer be supported. Consider using a newer version.")
      else
        response['count']
      end
    end

    def total_pages
      (total_records / page_size.to_f).ceil
    end

    def get_records(type:, page_size:, offset:)
      JSON.parse(HTTParty.get("#{base_url}/#{type}?navigationLink=false&size=#{page_size}&offset=#{offset}",
                              headers: { 'api-key' => pure_api_key,
                                         'Accept' => 'application/json' }).to_s)
    end
end
