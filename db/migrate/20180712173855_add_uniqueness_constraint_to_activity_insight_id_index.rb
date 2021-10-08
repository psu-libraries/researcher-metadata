# frozen_string_literal: true

class AddUniquenessConstraintToActivityInsightIdIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :users, :activity_insight_identifier
    add_index :users, :activity_insight_identifier, unique: true
  end

  def down
    remove_index :users, :activity_insight_identifier
    add_index :users, :activity_insight_identifier, unique: false
  end
end
