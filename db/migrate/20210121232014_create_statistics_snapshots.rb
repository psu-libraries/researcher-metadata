# frozen_string_literal: true

class CreateStatisticsSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics_snapshots do |t|
      t.integer :total_publication_count
      t.integer :open_access_publication_count
      t.timestamps null: false
    end
  end
end
