# frozen_string_literal: true

class RenameColumnsInGrantsTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :grants, :agency_name, :wos_agency_name
    rename_column :grants, :identifier, :wos_identifier
  end
end
