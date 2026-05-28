# frozen_string_literal: true

class OpenAlexAPIClient
  PSU_INSTITUATION_ID = 'I130769515'

  def get_works(type:, cursor: '*')
    response = HTTParty.get("https://api.openalex.org/works?filter=institutions.id:#{PSU_INSTITUATION_ID},type:#{type}&per_page=100&cursor=#{cursor}&api_key=#{api_key}")
    JSON.parse(response.body)
  end

  private

    def api_key
      Settings.open_alex.api_key
    end
end
