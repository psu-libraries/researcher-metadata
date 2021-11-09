class AddDeputyUserIdToInternalPublicationWaivers < ActiveRecord::Migration[6.1]
  def change
    add_column :internal_publication_waivers, :deputy_user_id, :bigint, null: true
    add_index :internal_publication_waivers, :deputy_user_id
    add_foreign_key :internal_publication_waivers, :users,
      column: :deputy_user_id,
      name: :internal_publication_waivers_deputy_user_id_fk
  end
end
