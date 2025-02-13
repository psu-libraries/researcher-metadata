# frozen_string_literal: true

class PureAPIClient
  private

    def api_version
      '524'
    end

    def base_url
      "https://pure.psu.edu/ws/api/#{api_version}"
    end

    def pure_api_key
      Settings.pure.api_key
    end
end
