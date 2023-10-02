class AddExportedOAStatusToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :exported_oa_status_to_activity_insight, :boolean
  end
end
