class CreateResearchFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :research_funds do |t|
      t.integer :grant_id, null: false
      t.integer :publication_id, null: false
      t.timestamps
    end

    add_index :research_funds, :grant_id
    add_index :research_funds, :publication_id

    add_foreign_key :research_funds, :grants, name: :research_funds_grant_id_fk, on_delete: :cascade
    add_foreign_key :research_funds, :publications, name: :research_funds_publication_id_fk, on_delete: :cascade
  end
end
