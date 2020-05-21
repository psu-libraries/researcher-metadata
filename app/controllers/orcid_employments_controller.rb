class OrcidEmploymentsController < UserController
  before_action :authenticate!

  def create
    membership = current_user.primary_organization_membership

    if membership.orcid_resource_identifier.present?
      flash[:notice] = I18n.t('profile.orcid_employments.create.already_added')
    else
      employment = OrcidEmployment.new(membership)
      employment.save!
      membership.update_attributes!(orcid_resource_identifier: employment.location)

      flash[:notice] = I18n.t('profile.orcid_employments.create.success')
    end
    
  rescue OrcidEmployment::InvalidToken
        current_user.clear_orcid_access_token
        flash[:alert] = I18n.t('profile.orcid_employments.create.account_not_linked')
  rescue OrcidEmployment::FailedRequest
        flash[:alert] = I18n.t('profile.orcid_employments.create.error')
  ensure
    redirect_to profile_bio_path
  end
end
