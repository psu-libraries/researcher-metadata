class OrcidEmployment
  class InvalidToken < RuntimeError; end
  class FailedRequest < RuntimeError; end

  attr_reader :location

  def initialize(user_organization_membership)
    @membership = user_organization_membership
  end

  def to_json
    employment = {
      organization: {
        name: "The Pennsylvania State University",
        address: {
          city: "University Park",
          region: "Pennsylvania",
          country: "US"
        },
        "disambiguated-organization": {
          "disambiguated-organization-identifier": "grid.29857.31",
          "disambiguation-source": "GRID"
        }
      },
      "department-name": membership.organization.name,
      "role-title": membership.position_title,
      "start-date": {
        year: membership.started_on.year,
        month: membership.started_on.month,
        day: membership.started_on.day
      }
    }

    if membership.ended_on
      employment[:"end-date"] = {
        year: membership.ended_on.year,
        month: membership.ended_on.month,
        day: membership.ended_on.day
      }
    end

    employment.to_json
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
    "employment"
  end

  def user
    membership.user
  end

  def access_token
    user.orcid_access_token
  end

  def orcid_id
    user.orcid
  end

  private

  attr_reader :membership
end
