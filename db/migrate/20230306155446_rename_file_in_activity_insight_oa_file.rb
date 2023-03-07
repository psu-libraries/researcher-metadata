class RenameFileInActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def change
    rename_column :activity_insight_oa_files, :file, :file_download_location
  end
end
