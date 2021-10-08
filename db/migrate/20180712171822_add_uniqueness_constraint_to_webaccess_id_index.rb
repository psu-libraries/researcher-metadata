# frozen_string_literal: true

class AddUniquenessConstraintToWebaccessIdIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :users, :webaccess_id
    add_index :users, :webaccess_id, unique: true
  end

  def down
    remove_index :users, :webaccess_id
    add_index :users, :webaccess_id, unique: false
  end
end
