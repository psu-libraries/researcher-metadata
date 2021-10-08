# frozen_string_literal: true

class AddActivityInsightIdColumnToUserPerformances < ActiveRecord::Migration[5.2]
  def change
    add_column :user_performances, :activity_insight_id, :integer
    add_index :user_performances, :activity_insight_id, unique: true
  end
end
