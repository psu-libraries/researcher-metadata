class CreateUserContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :user_contracts do |t|
      t.integer :user_id, null: false
      t.integer :contract_id, null: false

      t.timestamps
    end

    add_index :user_contracts, :user_id
    add_index :user_contracts, :contract_id

    add_foreign_key :user_contracts, :users, on_delete: :cascade
    add_foreign_key :user_contracts, :contracts, on_delete: :cascade
  end
end
