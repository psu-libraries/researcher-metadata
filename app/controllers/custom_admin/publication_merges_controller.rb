class CustomAdmin::PublicationMergesController < RailsAdmin::ApplicationController
  def create
    group = DuplicatePublicationGroup.find(params[:duplicate_publication_group_id])
    selected_pub = Publication.find(params[:publication_id])
    pubs_to_delete = group.publications - [selected_pub]

    ActiveRecord::Base.transaction do
      imports = group.publications.map { |p| p.imports }.flatten

      imports.each do |i|
        i.update_attributes!(publication: selected_pub)
      end

      pubs_to_delete.each do |p|
        p.destroy
      end

      selected_pub.update_attributes!(duplicate_group: nil,
                                      updated_by_user_at: Time.current)
      group.destroy
    end

    flash[:success] = I18n.t('admin.publication_merges.create.success')
    redirect_to rails_admin.edit_path(model_name: :publication, id: selected_pub.id)
  end
end