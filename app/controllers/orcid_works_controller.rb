# frozen_string_literal: true

class OrcidWorksController < UserController
  def create
    authorship = current_user.confirmed_authorships.find(params[:authorship_id])

    if authorship
      if authorship.orcid_resource_identifier.present?
        flash[:notice] = I18n.t('profile.orcid_works.create.already_added')
      else
        work = OrcidWork.new(authorship)
        work.save!
        authorship.update!(orcid_resource_identifier: work.location,
                           updated_by_owner_at: Time.current)

        flash[:notice] = I18n.t('profile.orcid_works.create.success')
      end
    end
  rescue OrcidWork::InvalidToken
    current_user.clear_orcid_access_token
    flash[:alert] = I18n.t('profile.orcid_works.create.account_not_linked')
  rescue OrcidWork::FailedRequest
    flash[:alert] = I18n.t('profile.orcid_works.create.error')
  ensure
    redirect_to edit_profile_publications_path
  end
end
