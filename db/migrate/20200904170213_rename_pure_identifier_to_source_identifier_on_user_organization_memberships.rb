# frozen_string_literal: true

class RenamePureIdentifierToSourceIdentifierOnUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def up
    remove_index :user_organization_memberships, :pure_identifier
    rename_column :user_organization_memberships, :pure_identifier, :source_identifier
    add_index :user_organization_memberships, :source_identifier
  end

  def down
    remove_index :user_organization_memberships, :source_identifier
    rename_column :user_organization_memberships, :source_identifier, :pure_identifier
    add_index :user_organization_memberships, :pure_identifier
  end
end
