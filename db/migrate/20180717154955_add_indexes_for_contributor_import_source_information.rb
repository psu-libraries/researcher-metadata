# frozen_string_literal: true

class AddIndexesForContributorImportSourceInformation < ActiveRecord::Migration[5.2]
  def change
    add_index :contributor_imports, :import_source
    add_index :contributor_imports, :source_identifier
  end
end
