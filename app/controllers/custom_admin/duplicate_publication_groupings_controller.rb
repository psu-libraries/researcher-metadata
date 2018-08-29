class CustomAdmin::DuplicatePublicationGroupingsController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:bulk_ids].present? && params[:bulk_ids].many?
      publications = Publication.find(params[:bulk_ids])
      DuplicatePublicationGroup.group_publications(publications)
      flash[:success] = I18n.t('admin.duplicate_publication_groupings.create.success')
    else
      flash[:error] = I18n.t('admin.duplicate_publication_groupings.create.no_pub_error')
    end

    redirect_to rails_admin.show_path(model_name: :user, id: params[:user_id])
  end
end