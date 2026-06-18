# frozen_string_literal: true

class AddScholarsphereEditURLToScholarsphereWorkDeposits < ActiveRecord::Migration[7.2]
  def change
    add_column :scholarsphere_work_deposits, :scholarsphere_edit_url, :string
  end
end
