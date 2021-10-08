class RemoveTitleColumnFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :title
  end

  def down
    add_column :users, :title, :string
  end
end
