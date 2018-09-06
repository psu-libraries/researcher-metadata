class CreateCommitteeMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :committee_memberships do |t|
      t.integer :etd_id, null: false
      t.integer :user_id, null: false
      t.string :role, null: false
      t.timestamps
    end

    add_index :committee_memberships, :etd_id
    add_index :committee_memberships, :user_id

    add_foreign_key :committee_memberships, :etds, on_delete: :cascade
    add_foreign_key :committee_memberships, :users, on_delete: :cascade
  end
end
