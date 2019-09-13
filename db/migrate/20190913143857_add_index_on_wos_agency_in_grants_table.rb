class AddIndexOnWOSAgencyInGrantsTable < ActiveRecord::Migration[5.2]
  def change
    add_index :grants, :wos_agency_name
  end
end
