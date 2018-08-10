class AddUpdatedByUserAtColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :updated_by_user_at, :datetime
  end
end
