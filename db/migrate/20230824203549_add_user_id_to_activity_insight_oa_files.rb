class AddUserIdToActivityInsightOAFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :activity_insight_oa_files, :user_id, :integer
    add_index :activity_insight_oa_files, :user_id
    add_foreign_key(
      :activity_insight_oa_files,
      :users,
      name: :activity_insight_oa_files_user_id_fk
    )
  end
end
