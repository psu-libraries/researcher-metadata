# frozen_string_literal: true

class RenameOrganizationsTypeColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :organizations, :type, :organization_type
  end
end
