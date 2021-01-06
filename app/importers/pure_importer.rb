class PureImporter
  private

  def base_url
    "https://pennstate.pure.elsevier.com/ws/api/516"
  end

  def pure_api_key
    Rails.configuration.x.pure['api_key']
  end

  def total_records
    get_records(type: record_type, page_size: 1, offset: 0)['count']
  end

  def get_records(type:, page_size:, offset:)
    JSON.parse(HTTParty.get("#{base_url}/#{type}?navigationLink=false&size=#{page_size}&offset=#{offset}",
                            headers: {"api-key" => pure_api_key,
                                      "Accept" => "application/json"}).to_s)
  end
end
