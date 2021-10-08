# frozen_string_literal: true

class CustomAdmin::DuplicatePublicationGroupsController < RailsAdmin::ApplicationController
  def delete
    group = DuplicatePublicationGroup.find(params[:id])

    if group.publications.count <= 1
      ActiveRecord::Base.transaction do
        group.publications.each { |p| p.update!(duplicate_group: nil) }
        group.destroy!
      end
      flash[:success] = I18n.t('admin.duplicate_publication_groups.delete.success')
    else
      flash[:error] = I18n.t('admin.duplicate_publication_groups.delete.multiple_publications_error')
    end

    redirect_to rails_admin.index_path(model_name: :duplicate_publication_group)
  end
end
