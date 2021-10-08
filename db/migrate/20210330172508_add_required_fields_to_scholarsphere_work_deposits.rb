# frozen_string_literal: true

class AddRequiredFieldsToScholarsphereWorkDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :scholarsphere_work_deposits, :title, :text
    add_column :scholarsphere_work_deposits, :description, :text
    add_column :scholarsphere_work_deposits, :published_date, :date
    add_column :scholarsphere_work_deposits, :rights, :string
  end
end
