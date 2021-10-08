# frozen_string_literal: true

class AddNewIdentifierColumnsToGrantsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :grants, :identifier, :string
    add_column :grants, :agency_name, :text

    add_index :grants, :identifier
    add_index :grants, :agency_name
  end
end
