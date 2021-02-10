class OrcidResource
  class InvalidToken < RuntimeError; end
  class FailedRequest < RuntimeError; end

  attr_reader :location

  def initialize(model)
    @model = model
  end

  def save!
    client = OrcidAPIClient.new(self)
    response = client.post

    if response.code == 201
      @location = response.headers["location"]
      return true
    else
      begin
        response_body = JSON.parse(response.to_s)
        if response_body["error"] == "invalid_token"
          raise InvalidToken
        else
          raise FailedRequest
        end
      rescue JSON::ParserError
        Rails.logger.error Nokogiri::XML(response.to_s).text
        raise FailedRequest
      end
    end
  end

  def to_json
    # Defined in subclass
  end

  def orcid_type
    # Defined in subclass
  end

  def user
    model.user
  end

  def access_token
    user.orcid_access_token
  end

  def orcid_id
    user.orcid_identifier
  end

  private

  attr_reader :model
end
