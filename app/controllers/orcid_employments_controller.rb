class OrcidEmploymentsController < UserController
  before_action :authenticate!

  def create
    membership = current_user.user_organization_memberships.where.not(pure_identifier: nil).first

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
      "role-title": membership.position_title
    }.to_json

    request = {
      headers: {
        "Content-type" => "application/vnd.orcid+json",
        "Authorization" => "Bearer #{current_user.orcid_access_token}",
      },
      body: employment
    }

    HTTParty.post("https://api.sandbox.orcid.org/v3.0/#{current_user.orcid_identifier}/employment",
                  request)

    redirect_to profile_bio_path
  end
end
