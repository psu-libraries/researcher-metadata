# frozen_string_literal: true

class RemoveImportedFromPureColumnFromUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def up
    remove_column :user_organization_memberships, :imported_from_pure
  end

  def down
    add_column :user_organization_memberships, :imported_from_pure, :boolean
  end
end
