# frozen_string_literal: true

class AddScopusHIndexColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :scopus_h_index, :integer
  end
end
