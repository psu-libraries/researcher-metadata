class AddPermissionsColumnsToActivityInsightOAFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :permissions_last_checked_at, :datetime
    add_column :activity_insight_oa_files, :license, :string
    add_column :activity_insight_oa_files, :embargo_date, :date
    add_column :activity_insight_oa_files, :set_statement, :text
    add_column :activity_insight_oa_files, :checked_for_set_statement, :boolean
    add_column :activity_insight_oa_files, :checked_for_embargo_date, :boolean
  end
end
