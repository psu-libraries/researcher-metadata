class AddOrcidResourceIdentifierToUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :user_organization_memberships, :orcid_resource_identifier, :string
  end
end
