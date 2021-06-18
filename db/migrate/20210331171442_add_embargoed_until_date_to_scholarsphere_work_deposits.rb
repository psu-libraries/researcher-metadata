class AddEmbargoedUntilDateToScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :scholarsphere_work_deposits, :embargoed_until, :date
  end
end
