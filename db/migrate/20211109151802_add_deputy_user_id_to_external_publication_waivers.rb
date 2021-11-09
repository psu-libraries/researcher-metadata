class AddDeputyUserIdToExternalPublicationWaivers < ActiveRecord::Migration[6.1]
  def change
    add_column :external_publication_waivers, :deputy_user_id, :bigint, null: true
    add_index :external_publication_waivers, :deputy_user_id
    add_foreign_key :external_publication_waivers, :users,
      column: :deputy_user_id,
      name: :external_publication_waivers_deputy_user_id_fk
  end
end
