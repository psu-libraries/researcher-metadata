# frozen_string_literal: true

class AddRoleColumnsToAuthorshipsAndContributors < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :role, :string
    add_column :contributors, :role, :string
  end
end
