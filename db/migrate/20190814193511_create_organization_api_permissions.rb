# frozen_string_literal: true

class CreateOrganizationAPIPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_api_permissions do |t|
      t.integer :api_token_id, null: false
      t.integer :organization_id, null: false
      t.timestamps
    end

    add_index :organization_api_permissions, :api_token_id
    add_index :organization_api_permissions, :organization_id

    add_foreign_key :organization_api_permissions, :api_tokens, name: :organization_api_permissions_api_token_id_fk, on_delete: :cascade
    add_foreign_key :organization_api_permissions, :organizations, name: :organization_api_permissions_organization_id_fk, on_delete: :cascade
  end
end
