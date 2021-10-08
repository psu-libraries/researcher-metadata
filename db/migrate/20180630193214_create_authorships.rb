class CreateAuthorships < ActiveRecord::Migration[5.2]
  def change
    create_table :authorships do |t|
      t.integer :person_id
      t.integer :publication_id
      t.integer :author_number
      t.string :activity_insight_identifier

      t.timestamps
    end

    add_index :authorships, :person_id
    add_index :authorships, :publication_id

    add_foreign_key :authorships, :people, name: :authorships_person_id_fk
    add_foreign_key :authorships, :publications, name: :authorships_publication_id_fk
  end
end
