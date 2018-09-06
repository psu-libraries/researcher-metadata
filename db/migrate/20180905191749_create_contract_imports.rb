class CreateContractImports < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_imports do |t|
      t.integer :contract_id, null: false
      t.integer :activity_insight_id, null: false

      t.timestamps
    end

    add_index :contract_imports, :activity_insight_id, unique: true
    add_index :contract_imports, :contract_id

    add_foreign_key :contract_imports, :contracts, name: :contract_imports_contract_id_fk
  end
end
