class AddColumnsToGrantsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :grants, :title, :text
    add_column :grants, :start_date, :date
    add_column :grants, :end_date, :date
    add_column :grants, :abstract, :text
    add_column :grants, :amount_in_dollars, :integer
  end
end
