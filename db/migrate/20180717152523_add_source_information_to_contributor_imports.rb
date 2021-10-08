# frozen_string_literal: true

class AddSourceInformationToContributorImports < ActiveRecord::Migration[5.2]
  def change
    add_column :contributor_imports, :import_source, :string, null: false
    add_column :contributor_imports, :source_identifier, :string, null: false
  end
end
