class AddConfirmedColumnToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :confirmed, :boolean, default: true
  end
end
