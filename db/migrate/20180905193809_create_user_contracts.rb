class CreateUserContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :user_contracts do |t|
      t.integer :user_id, null: false
      t.integer :contract_id, null: false

      t.timestamps
    end

    add_index :user_contracts, :user_id
    add_index :user_contracts, :contract_id

    add_foreign_key :user_contracts, :users, name: :user_contracts_user_id_fk
    add_foreign_key :user_contracts, :contracts, name: :user_contracts_contract_id_fk
  end
end
