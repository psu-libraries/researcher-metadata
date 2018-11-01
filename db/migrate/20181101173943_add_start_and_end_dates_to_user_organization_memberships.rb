class AddStartAndEndDatesToUserOrganizationMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :user_organization_memberships, :started_on, :date
    add_column :user_organization_memberships, :ended_on, :date
  end
end
