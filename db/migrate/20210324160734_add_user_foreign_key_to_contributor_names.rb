class AddUserForeignKeyToContributorNames < ActiveRecord::Migration[5.2]
  def change
    add_reference :contributor_names, :user, foreign_key: true
  end
end
