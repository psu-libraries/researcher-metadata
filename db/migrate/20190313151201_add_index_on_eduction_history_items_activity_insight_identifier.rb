class AddIndexOnEductionHistoryItemsActivityInsightIdentifier < ActiveRecord::Migration[5.2]
  def change
    add_index :education_history_items, :activity_insight_identifier, unique: true
  end
end
