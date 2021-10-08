class ChangePublicationsForeignKeyOnAuthorships < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :authorships, :publications
    add_foreign_key :authorships, :publications, on_delete: :cascade
  end
end
