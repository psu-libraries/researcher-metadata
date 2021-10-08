# frozen_string_literal: true

class AddOwnerIdToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :owner_id, :integer
    add_index :organizations, :owner_id
    add_foreign_key :organizations, :users, column: :owner_id, name: :organizations_owner_id_fk
  end
end
