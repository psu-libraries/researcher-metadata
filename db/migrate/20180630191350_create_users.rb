class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :webaccess_id
      t.integer :person_id
      t.boolean :is_admin, default: false

      t.timestamps
    end

    add_index :users, :person_id

    add_foreign_key :users, :people, name: :users_person_id_fk
  end
end
