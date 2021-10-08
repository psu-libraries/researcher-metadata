# frozen_string_literal: true

class CreateNonDuplicatePublicationGroupMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :non_duplicate_publication_group_memberships do |t|
      t.integer :publication_id, null: false
      t.integer :non_duplicate_publication_group_id, null: false
      t.timestamps null: false
    end

    add_index :non_duplicate_publication_group_memberships, :publication_id, name: :index_ndpg_memberships_on_publication_id
    add_index :non_duplicate_publication_group_memberships, :non_duplicate_publication_group_id, name: :index_ndpg_memberships_on_ndpg_id

    add_foreign_key :non_duplicate_publication_group_memberships, :publications, name: :non_duplicate_publication_group_membership_publication_id_fk, on_delete: :cascade
    add_foreign_key :non_duplicate_publication_group_memberships, :non_duplicate_publication_groups, name: :non_duplicate_publication_group_membership_group_id_fk, on_delete: :cascade
  end
end
