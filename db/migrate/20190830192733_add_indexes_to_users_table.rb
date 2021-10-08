# frozen_string_literal: true

class AddIndexesToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :orcid_identifier, unique: true
    add_index :users, :first_name
    add_index :users, :middle_name
    add_index :users, :last_name
  end
end
