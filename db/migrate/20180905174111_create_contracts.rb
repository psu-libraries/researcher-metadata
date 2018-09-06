class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.text :title
      t.string :contract_type
      t.text :sponsor
      t.integer :amount
      t.integer :ospkey
      t.date :award_start_on
      t.date :award_end_on
      t.timestamps
    end

    add_index :contracts, :ospkey, unique: true
  end
end
