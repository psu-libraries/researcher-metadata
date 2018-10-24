class ChangePerformanceColumns < ActiveRecord::Migration[5.2]
  def change
    remove_index :performances, name: "index_performances_on_activity_insight_id"
    remove_column :performances, :activity_insight_id
    add_column :performances, :visible, :boolean, default: false
  end
end
