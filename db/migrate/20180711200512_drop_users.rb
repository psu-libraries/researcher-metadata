class DropUsers < ActiveRecord::Migration[5.2]
  def up
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new 'This migration deletes data and connot be reversed.'
  end
end
