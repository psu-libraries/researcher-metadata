# frozen_string_literal: true

class CreateContributorImports < ActiveRecord::Migration[5.2]
  def change
    create_table :contributor_imports do |t|
      t.integer :publication_import_id, null: false
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.integer :position, null: false
      t.timestamps
    end

    add_index :contributor_imports, :publication_import_id
    add_foreign_key :contributor_imports,
                    :publication_imports,
                    name: :contributor_imports_publication_import_id_fk
  end
end
