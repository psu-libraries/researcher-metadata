class RemoveInstitutionFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :institution
  end
end
