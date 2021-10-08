class RenamePersonFkOnAuthorship < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :authorships, column: :person_id
    rename_column :authorships, :person_id, :user_id
    add_foreign_key :authorships, :users
  end

  def down
    remove_foreign_key :authorships, column: :user_id
    rename_column :authorships, :user_id, :person_id
    add_foreign_key :authorships, :users, column: :person_id, name: :authorships_person_id_fk
  end
end
