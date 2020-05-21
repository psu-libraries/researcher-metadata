class AddOrcidAuthorizationFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :orcid_refresh_token
      t.string :orcid_access_token_scope
      t.integer :orcid_access_token_expires_in
      t.string :authenticated_orcid_identifier
    end
  end
end
