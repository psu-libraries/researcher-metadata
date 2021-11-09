class AddDeputyUserIdToScholarsphereWorkDeposits < ActiveRecord::Migration[6.1]
  def change
    add_column :scholarsphere_work_deposits, :deputy_user_id, :bigint, null: true
    add_index :scholarsphere_work_deposits, :deputy_user_id
    add_foreign_key :scholarsphere_work_deposits, :users,
      column: :deputy_user_id,
      name: :scholarsphere_work_deposits_deputy_user_id_fk
  end
end
