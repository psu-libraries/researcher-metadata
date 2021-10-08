# frozen_string_literal: true

class CreateUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :user_organization_memberships do |t|
      t.integer :user_id, null: false
      t.integer :organization_id, null: false
      t.string :pure_identifier
      t.boolean :imported_from_pure
      t.string :position_title
      t.boolean :primary
      t.datetime :updated_by_user_at
      t.timestamps
    end

    add_index :user_organization_memberships, :user_id
    add_index :user_organization_memberships, :organization_id
    add_index :user_organization_memberships, :pure_identifier

    add_foreign_key :user_organization_memberships, :users, name: :user_organization_memberships_user_id_fk, on_delete: :cascade
    add_foreign_key :user_organization_memberships, :organizations, name: :user_organization_memberships_organization_id_fk, on_delete: :cascade
  end
end
