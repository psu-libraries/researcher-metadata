# frozen_string_literal: true

class PureAPIClient
  private

    def base_url
      'https://pure.psu.edu/ws/api'
    end

    def pure_api_key
      Settings.pure.api_key
    end
end
