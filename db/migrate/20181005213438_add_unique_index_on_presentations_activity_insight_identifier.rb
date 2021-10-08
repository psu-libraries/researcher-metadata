# frozen_string_literal: true

class AddUniqueIndexOnPresentationsActivityInsightIdentifier < ActiveRecord::Migration[5.2]
  def change
    add_index :presentations, :activity_insight_identifier, unique: true
  end
end
