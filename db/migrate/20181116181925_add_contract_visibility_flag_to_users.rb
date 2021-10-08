# frozen_string_literal: true

class AddContractVisibilityFlagToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :show_all_contracts, :boolean, default: false
  end
end
