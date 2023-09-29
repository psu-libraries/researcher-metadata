class MoveExportedOAStatusToActivityInsightToActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def change
    remove_column :publications, :exported_oa_status_to_activity_insight, :boolean
    add_column :activity_insight_oa_files, :exported_oa_status_to_activity_insight, :boolean
  end
end
