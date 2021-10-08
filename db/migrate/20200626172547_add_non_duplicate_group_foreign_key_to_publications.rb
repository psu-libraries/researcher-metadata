# frozen_string_literal: true

class AddNonDuplicateGroupForeignKeyToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :non_duplicate_publication_group_id, :integer

    add_foreign_key :publications,
                    :non_duplicate_publication_groups,
                    name: :publications_non_duplicate_publication_group_id_fk

    add_index :publications, :non_duplicate_publication_group_id
  end
end
