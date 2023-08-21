class AddVersionToActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :version, :string
    add_column :activity_insight_oa_files, :version_checked, :boolean
  end
end
