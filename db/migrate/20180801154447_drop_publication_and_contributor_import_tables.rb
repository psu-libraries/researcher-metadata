# frozen_string_literal: true

class DropPublicationAndContributorImportTables < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :publication_imports, :publications
    remove_foreign_key :contributor_imports, :publication_imports
    drop_table :publication_imports
    drop_table :contributor_imports
  end
end
