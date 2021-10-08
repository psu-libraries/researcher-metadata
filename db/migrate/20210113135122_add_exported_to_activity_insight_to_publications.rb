# frozen_string_literal: true

class AddExportedToActivityInsightToPublications < ActiveRecord::Migration[5.2]
  def self.up
    add_column :publications, :exported_to_activity_insight, :boolean
  end

  def self.down
    remove_column :publications, :exported_to_activity_insight
  end
end
