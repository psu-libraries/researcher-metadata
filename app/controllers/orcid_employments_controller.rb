class OrcidEmploymentsController < UserController
  before_action :authenticate!

  def create
    membership = current_user.primary_organization_membership

    if membership.orcid_resource_identifier.present?
      flash[:notice] = "The employment record has already been added to your ORCID profile."
    else
      employment = OrcidEmployment.new(membership)
      employment.save!
      membership.update_attributes!(orcid_resource_identifier: employment.location)

      flash[:notice] = "The employment record was successfully added to your ORCiD profile."
    end
    
  rescue OrcidEmployment::InvalidToken
        current_user.clear_orcid_access_token
        flash[:alert] = "Your ORCiD account is no longer linked to your metadata profile."
  rescue OrcidEmployment::FailedRequest
        flash[:alert] = "There was an error adding your employment history to your ORCiD profile."
  ensure
    redirect_to profile_bio_path
  end
end
