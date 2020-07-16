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
          title: publication.title,
          subtitle: publication.secondary_title,
          "translated-title": nil
      },
      "journal-title": publication.journal_title,
      "short-description": publication.abstract,
      type: publication.publication_type,
      "publication-date": {
          year: publication.published_on.year,
          month: publication.published_on.month,
          day: publication.published_on.day
      },
      url: publication.url
    }

    external_ids.each do |type|
      if publication.send(type).present?
        relationship = (type == :doi ? 'self' : 'part-of')
        work[:"external-ids"] = { "external-id": [] } unless work[:"external-ids"].present?
        work[:"external-ids"][:"external-id"] << {
                "external-id-type": type.to_s,
                "external-id-value": publication.send(type).to_s,
                "external-id-relationship": relationship
        }
      end
    end

    publication.authorships.each do |ext_author|
      next if ext_author.user.id == user.id

      work[:contributors] = { contributor: [] } unless work[:contributors].present?
      work[:contributors][:contributor] << {
          "contributor-orcid": {
              uri: "https://orcid.org/#{ext_author.user.orcid_identifier}",
              path: ext_author.user.orcid_identifier.to_s,
              host: 'orcid.org'
          },
          "credit-name": "#{ext_author.user.first_name} #{ext_author.user.middle_name} #{ext_author.user.last_name}",
          "contributor-attributes": {
              "contributor-sequence": ext_author.author_number.to_s,
              "contributor-role": ext_author.role
          }
      }
    end

    work.to_json
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

  def publication
    authorship.publication
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