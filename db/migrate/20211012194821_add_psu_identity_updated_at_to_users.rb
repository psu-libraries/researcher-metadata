class AddPSUIdentityUpdatedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :psu_identity_updated_at, :timestamp
  end
end
