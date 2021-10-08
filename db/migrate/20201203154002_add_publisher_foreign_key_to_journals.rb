# frozen_string_literal: true

class AddPublisherForeignKeyToJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :publisher_id, :integer

    add_index :journals, :publisher_id

    add_foreign_key :journals, :publishers
  end
end
