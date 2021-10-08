# frozen_string_literal: true

class AddPublisherStatementToScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :scholarsphere_work_deposits, :publisher_statement, :text
  end
end
