# frozen_string_literal: true

class AddPureAndActivityInsightIdentifiersToContributors < ActiveRecord::Migration[5.2]
  def change
    add_column :contributors, :pure_identifier, :string
    add_column :contributors, :activity_insight_identifier, :string

    add_index :contributors, :pure_identifier, unique: true
    add_index :contributors, :activity_insight_identifier, unique: true
  end
end
