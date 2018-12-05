class ChangeUserPerformanceColumnActivityInsightId < ActiveRecord::Migration[5.2]
  def change
    change_column_null :user_performances, :activity_insight_id, false
  end
end
