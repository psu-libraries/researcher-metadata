class AddVersionFieldToActivityInsightOaFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :version, :string
  end
end
