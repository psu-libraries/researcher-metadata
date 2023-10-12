class AddDepositWorkflowToScholarsphereWorkDeposits < ActiveRecord::Migration[6.1]
  def change
    add_column :scholarsphere_work_deposits, :deposit_workflow, :string
  end
end
