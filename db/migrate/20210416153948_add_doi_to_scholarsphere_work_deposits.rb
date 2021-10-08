# frozen_string_literal: true

class AddDOIToScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :scholarsphere_work_deposits, :doi, :string
  end
end
