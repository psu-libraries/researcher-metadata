class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.text :title, null: false
      t.string :contract_type
      t.text :sponsor, null: false
      t.text :status, null: false
      t.integer :amount, null: false
      t.integer :ospkey, null: false
      t.date :award_start_on, null: false
      t.date :award_end_on, null: false
      t.timestamps
    end

    add_index :contracts, :ospkey, unique: true
  end
end
