# frozen_string_literal: true

class RenamePeopleToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :people, :users
  end
end
