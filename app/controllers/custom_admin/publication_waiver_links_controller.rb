class CustomAdmin::PublicationWaiverLinksController < RailsAdmin::ApplicationController
  def create
    ext_waiver = ExternalPublicationWaiver.find(params[:external_publication_waiver_id])
    pub = Publication.find(params[:publication_id])
    
    auth = pub.authorships.find_by(user: ext_waiver.user)

    if auth
      existing_int_waiver = InternalPublicationWaiver.find_by(authorship: auth)

      if existing_int_waiver
        flash[:error] = "A waiver from this user has already been linked to the selected publication."
        redirect_to rails_admin.show_path(model_name: :external_publication_waiver, id: params[:external_publication_waiver_id])
      else
        ActiveRecord::Base.transaction do
          new_int_waiver = InternalPublicationWaiver.new
          new_int_waiver.authorship = auth
          new_int_waiver.reason_for_waiver = ext_waiver.reason_for_waiver
          new_int_waiver.save!
          ext_waiver.internal_publication_waiver = new_int_waiver
          ext_waiver.save!
        end

        flash[:success] = "The waiver was successfully linked to the selected publication."
        redirect_to rails_admin.index_path(model_name: :external_publication_waiver)
      end
    else
      flash[:error] = "The user who submitted this waiver is not listed as one of the authors of the selected publication. If this is the correct publication for this waiver and the submitting user is actually an author, then please add the missing authorship data to this publication and try again."
      redirect_to rails_admin.show_path(model_name: :external_publication_waiver, id: params[:external_publication_waiver_id])
    end
  end
end
