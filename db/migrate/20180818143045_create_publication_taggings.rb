# frozen_string_literal: true

class CreatePublicationTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_taggings do |t|
      t.integer :publication_id, null: false
      t.integer :tag_id, null: false
      t.integer :rank
      t.timestamps
    end

    add_index :publication_taggings, :publication_id
    add_index :publication_taggings, :tag_id

    add_foreign_key :publication_taggings, :publications, on_delete: :cascade
    add_foreign_key :publication_taggings, :tags, on_delete: :cascade
  end
end
