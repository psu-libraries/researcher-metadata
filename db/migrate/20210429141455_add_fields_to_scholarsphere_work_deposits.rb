class AddFieldsToScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :scholarsphere_work_deposits, :subtitle, :text
    add_column :scholarsphere_work_deposits, :publisher, :string
  end
end
