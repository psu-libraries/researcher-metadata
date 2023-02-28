class AddDownloadedToActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :file, :string
    add_column :activity_insight_oa_files, :downloaded, :boolean
  end
end
