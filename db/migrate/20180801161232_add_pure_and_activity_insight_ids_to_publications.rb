# frozen_string_literal: true

class AddPureAndActivityInsightIdsToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :pure_uuid, :string
    add_column :publications, :activity_insight_identifier, :string

    add_index :publications, :pure_uuid, unique: true
    add_index :publications, :activity_insight_identifier, unique: true
  end
end
