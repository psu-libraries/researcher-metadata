class AddPSUIdentityToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :psu_identity, :jsonb
  end
end
