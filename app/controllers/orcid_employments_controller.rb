class OrcidEmploymentsController < UserController
  before_action :authenticate!

  def create
    membership = current_user.primary_organization_membership

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

    request = {
      headers: {
        "Content-type" => "application/vnd.orcid+json",
        "Authorization" => "Bearer #{current_user.orcid_access_token}",
      },
      body: employment.to_json
    }

    response = HTTParty.post("https://api.sandbox.orcid.org/v3.0/#{current_user.orcid}/employment",
                  request)

    if response.code == 201
      flash[:notice] = "The employment record was successfully added to your ORCiD profile."
    else
      response_body = JSON.parse(response.to_s)
      if response_body["error"] == "invalid_token"
        current_user.clear_orcid_access_token
        flash[:alert] = "Your ORCiD account is no longer linked to your metadata profile."
      else
        flash[:alert] = "There was an error adding your employment history to your ORCiD profile."
      end
    end

    redirect_to profile_bio_path
  end
end
