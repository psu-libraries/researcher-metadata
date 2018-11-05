class AddUniqueIndexOnActivityInsightIdForPerformances < ActiveRecord::Migration[5.2]
  def change
    add_index :performances, :activity_insight_id, unique: true
  end
end
