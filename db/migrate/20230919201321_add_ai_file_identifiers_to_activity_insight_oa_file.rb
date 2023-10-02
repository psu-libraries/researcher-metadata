class AddAiFileIdentifiersToActivityInsightOAFile < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :intellcont_id, :string
    add_column :activity_insight_oa_files, :post_file_id, :string
  end
end
