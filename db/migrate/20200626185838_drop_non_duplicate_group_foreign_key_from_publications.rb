# frozen_string_literal: true

class DropNonDuplicateGroupForeignKeyFromPublications < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :publications,
                       :non_duplicate_publication_groups
    remove_index :publications, :non_duplicate_publication_group_id
    remove_column :publications, :non_duplicate_publication_group_id, :integer
  end
end
