# frozen_string_literal: true

class AddUserAttributesToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :is_admin, :boolean
    add_column :people, :webaccess_id, :string
    add_index :people, :webaccess_id
  end
end
