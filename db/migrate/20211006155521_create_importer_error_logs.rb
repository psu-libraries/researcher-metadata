# frozen_string_literal: true

class CreateImporterErrorLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :importer_error_logs do |t|
      t.string :importer_type, null: false
      t.string :error_type, null: false
      t.text :stacktrace, null: false
      t.datetime :occurred_at, null: false
      t.jsonb :metadata
      t.timestamps
    end
    add_index :importer_error_logs, :importer_type
  end
end
