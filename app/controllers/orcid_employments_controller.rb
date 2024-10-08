# frozen_string_literal: true

class OrcidEmploymentsController < UserController
  def create
    membership = current_user.user_organization_memberships.find(params[:membership_id])

    if membership
      if membership.orcid_resource_identifier.present?
        flash[:notice] = I18n.t('profile.orcid_employments.create.already_added')
      else
        employment = OrcidEmployment.new(membership)
        employment.save!
        membership.update!(orcid_resource_identifier: employment.location)

        flash[:notice] = I18n.t('profile.orcid_employments.create.success')
      end
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
