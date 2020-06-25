class CustomAdmin::PublicationMergesController < RailsAdmin::ApplicationController
  def create
    group = DuplicatePublicationGroup.find(params[:duplicate_publication_group_id])

    if params[:commit] == 'Merge Selected'
      if params[:merge_target_publication_id].blank? ||
         params[:selected_publication_ids].blank? ||
          params[:selected_publication_ids] == [params[:merge_target_publication_id]]
        flash[:error] = "To perform a merge, you must select a merge target and at least one other publication to merge into the target."
        redirect_to rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id)
        return
      end

      merge_target_pub = group.publications.find(params[:merge_target_publication_id])
      selected_pubs = group.publications.find(params[:selected_publication_ids])
      pubs_to_delete = selected_pubs - [merge_target_pub]

      ActiveRecord::Base.transaction do
        imports_to_reassign = pubs_to_delete.map { |p| p.imports }.flatten

        imports_to_reassign.each do |i|
          i.update_attributes!(publication: merge_target_pub)
        end

        pubs_to_delete.each do |p|
          p.destroy
        end

        merge_target_pub.update_attributes!(updated_by_user_at: Time.current)
      end

      flash[:success] = I18n.t('admin.publication_merges.create.success')
    elsif params[:commit] = 'Ignore Selected'
      flash[:alert] = "This feature has not been implemented yet."
    end

    redirect_to rails_admin.show_path(model_name: :duplicate_publication_group, id: group.id)
  end
end