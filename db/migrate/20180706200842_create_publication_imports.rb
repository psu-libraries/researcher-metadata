class CreatePublicationImports < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_imports do |t|
      t.text :title, null: false
      t.integer :publication_id, null: false
      t.string :import_source, null: false
      t.string :source_identifier, null: false
      t.datetime :source_updated_at
      t.string :type, null: false
      t.text :journal_title
      t.text :publisher
      t.text :secondary_title
      t.string :status
      t.string :volume
      t.string :issue
      t.string :edition
      t.string :page_range
      t.text :url
      t.string :isbn
      t.string :issn
      t.string :doi
      t.text :abstract
      t.boolean :authors_et_al
      t.datetime :published_at
      t.timestamps
    end

    add_index :publication_imports, :source_identifier
    add_index :publication_imports, :import_source
    add_index :publication_imports, :publication_id

    add_foreign_key :publication_imports, :publications, name: :publication_imports_publication_id_fk
  end
end
