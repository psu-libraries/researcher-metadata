# frozen_string_literal: true

class RecreatePublicationImports < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_imports do |t|
      t.integer :publication_id, null: false
      t.string :source, null: false
      t.string :source_identifier, null: false
      t.datetime :source_updated_at
      t.timestamps
    end

    add_index :publication_imports, :publication_id
    add_index :publication_imports, [:source_identifier, :source], unique: true
    add_foreign_key :publication_imports, :publications, name: :publication_imports_publication_id_fk
  end
end
