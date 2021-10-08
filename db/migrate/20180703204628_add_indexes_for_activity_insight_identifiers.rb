class AddIndexesForActivityInsightIdentifiers < ActiveRecord::Migration[5.2]
  def change
    add_index :people, :activity_insight_identifier
    add_index :publications, :activity_insight_identifier
  end
end
