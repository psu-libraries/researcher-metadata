class OrcidWork
  class InvalidToken < RuntimeError; end
  class FailedRequest < RuntimeError; end

  attr_reader :location

  def initialize(authorship)
    @authorship = authorship
  end

  def to_json
    external_ids = %i[isbn issn doi]

    work = {
      title: {
          title: {
              value: authorship.publication.title
          },
          subtitle: authorship.publication.secondary_title,
          "translated-title": nil
      },
      "journal-title": {
          value: authorship.publication.journal_title
      },
      "short-description": authorship.publication.abstract,
      type: authorship.publication.publication_type,
      "publication-date": {
          year: Date.parse(authorship.publication.published_on).year,
          month: Date.parse(authorship.publication.published_on).month,
          day: Date.parse(authorship.publication.published_on).day
      }
    }

    external_ids.each do |type|
      if authorship.publication.send(type).present?
        relationship = (type == i%[doi] ? 'self' : 'part-of')
        work[:"external-ids"][:"external-id"] << {
                "external-id-type": type.to_s,
                "external-id-value": authorship.publication.send(type).to_s,
                "external-id-relationship": relationship
        }
      end
    end
  end

  def save!
    client = OrcidAPIClient.new(self)
    response = client.post

    if response.code == 201
      @location = response.headers["location"]
      return true
    else
      response_body = JSON.parse(response.to_s)
      if response_body["error"] == "invalid_token"
        raise InvalidToken
      else
        raise FailedRequest
      end
    end
  end

  def orcid_type
    "work"
  end

  def user
    authorship.user
  end

  def access_token
    user.orcid_access_token
  end

  def orcid_id
    user.authenticated_orcid_identifier
  end

  private

  attr_reader :authorship
end