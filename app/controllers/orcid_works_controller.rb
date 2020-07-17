class OrcidWorksController < UserController
  def create
    byebug
    authorship = Authorship.find(params[:authorship_id])

    if authorship
      if authorship.orcid_resource_identifier.present?
        flash[:notice] = I18n.t('profile.orcid_works.create.already_added')
      else
        work = OrcidWork.new(authorship)
        work.save!
        work.update_attributes!(orcid_resource_identifier: work.location)

        flash[:notice] = I18n.t('profile.orcid_works.create.success')
      end
    end

  rescue OrcidWork::InvalidToken
    current_user.clear_orcid_access_token
    flash[:alert] = I18n.t('profile.orcid_works.create.account_not_linked')
  rescue OrcidWork::FailedRequest
    flash[:alert] = I18n.t('profile.orcid_works.create.error')
  ensure
    redirect_to profile_bio_path
  end
end
