class CreateScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    create_table :scholarsphere_work_deposits do |t|
      t.references :authorship, foreign_key: true
      t.string :status
      t.text :error_message
      t.datetime :deposited_at
      t.timestamps null: false
    end
  end
end
