class AddDefaultToAuthorshipsVisibleInProfileColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :authorships, :visible_in_profile, :boolean, default: true
  end
end
