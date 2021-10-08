class CreateExternalPublicationWaivers < ActiveRecord::Migration[5.2]
  def change
    create_table :external_publication_waivers do |t|
      t.integer :user_id, null: false
      t.text :publication_title, null: false
      t.text :reason_for_waiver
      t.text :abstract
      t.string :doi
      t.string :journal_title, null: false
      t.string :publisher
      t.timestamps null: false
    end

    add_index :external_publication_waivers, :user_id
    add_foreign_key :external_publication_waivers, :users, name: :external_publication_waivers_user_id_fk
  end
end
