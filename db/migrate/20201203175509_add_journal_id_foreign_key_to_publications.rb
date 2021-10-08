# frozen_string_literal: true

class AddJournalIdForeignKeyToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :journal_id, :integer

    add_index :publications, :journal_id

    add_foreign_key :publications, :journals
  end
end
