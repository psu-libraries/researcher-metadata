class CreateGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :grants do |t|
      t.text :agency_name, null: false
      t.string :identifier
      t.timestamps
    end

    add_index :grants, :identifier
  end
end
