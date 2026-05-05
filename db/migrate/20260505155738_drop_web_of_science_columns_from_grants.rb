class DropWebOfScienceColumnsFromGrants < ActiveRecord::Migration[7.2]
  def up
    remove_column :grants, :wos_identifier
    remove_column :grants, :wos_agency_name
  end

  def down
    add_column :grants, :wos_identifier, :string
    add_column :grants, :wos_agency_name, :text

    add_index :grants, :wos_identifier
    add_index :grants, :wos_agency_name
  end
end
