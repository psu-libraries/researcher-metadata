class AddActivityInsightIdToPerformances < ActiveRecord::Migration[5.2]
  def change
    add_column :performances, :activity_insight_id, :bigint, null: false
  end
end
