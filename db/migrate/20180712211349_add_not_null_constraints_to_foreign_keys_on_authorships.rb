class AddNotNullConstraintsToForeignKeysOnAuthorships < ActiveRecord::Migration[5.2]
  def change
    change_column_null :authorships, :user_id, false
    change_column_null :authorships, :publication_id, false
  end
end
