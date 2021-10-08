# frozen_string_literal: true

class CreateContributors < ActiveRecord::Migration[5.2]
  def change
    create_table :contributors do |t|
      t.integer :publication_id, null: false
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.integer :position, null: false
      t.timestamps
    end

    add_index :contributors, :publication_id
    add_foreign_key :contributors, :publications, name: :contributors_publication_id_fk
  end
end
