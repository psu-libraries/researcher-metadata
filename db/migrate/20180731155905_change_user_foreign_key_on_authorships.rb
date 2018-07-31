class ChangeUserForeignKeyOnAuthorships < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :authorships, :users
    add_foreign_key :authorships, :users, on_delete: :cascade
  end
end
