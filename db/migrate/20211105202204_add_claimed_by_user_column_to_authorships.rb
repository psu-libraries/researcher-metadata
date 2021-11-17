class AddClaimedByUserColumnToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :claimed_by_user, :boolean, default: false
  end
end
