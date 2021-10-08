# frozen_string_literal: true

class AddVisibilityFlagToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :visible, :boolean, default: false
  end
end
