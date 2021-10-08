# frozen_string_literal: true

class AddActivityInsightIdColumnToPerformanceScreenings < ActiveRecord::Migration[5.2]
  def change
    add_column :performance_screenings, :activity_insight_id, :bigint, null: false
    add_index :performance_screenings, :activity_insight_id, unique: true
  end
end
