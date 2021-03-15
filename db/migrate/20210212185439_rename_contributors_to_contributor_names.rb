class RenameContributorsToContributorNames < ActiveRecord::Migration[5.2]
  def change
    rename_table :contributors, :contributor_names
  end
end
