# frozen_string_literal: true

class AddUniqueIndexToAuthorshipsActivityInsightIdentifier < ActiveRecord::Migration[5.2]
  def change
    add_index :authorships, :activity_insight_identifier, unique: true
  end
end
