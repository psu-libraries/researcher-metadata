# frozen_string_literal: true

class AddImportSourceToUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :user_organization_memberships, :import_source, :string
    add_index :user_organization_memberships, :import_source
  end
end
