class CreateEtds < ActiveRecord::Migration[5.2]
  def change
    create_table :etds do |t|
      t.text :title, null: false
      t.string :author_first_name, null: false
      t.string :author_last_name, null: false
      t.string :author_middle_name
      t.string :webaccess_id, null: false
      t.integer :year, null: false
      t.text :url, null: false
      t.string :submission_type, null: false
      t.string :external_identifier, null: false
      t.string :access_level, null: false
      t.timestamps
    end

    add_index :etds, :webaccess_id
    add_index :etds, :external_identifier
  end
end
