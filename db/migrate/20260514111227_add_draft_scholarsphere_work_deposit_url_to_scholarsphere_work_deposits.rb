class AddDraftScholarsphereWorkDepositURLToScholarsphereWorkDeposits < ActiveRecord::Migration[7.2]
  def change
    add_column :scholarsphere_work_deposits, :draft_scholarsphere_work_deposit_url, :string
  end
end
