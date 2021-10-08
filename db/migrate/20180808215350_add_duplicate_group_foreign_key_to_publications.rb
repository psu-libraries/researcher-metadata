# frozen_string_literal: true

class AddDuplicateGroupForeignKeyToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :duplicate_publication_group_id, :integer

    add_foreign_key :publications,
                    :duplicate_publication_groups,
                    name: :publications_duplicate_publication_group_id_fk

    add_index :publications, :duplicate_publication_group_id
  end
end
