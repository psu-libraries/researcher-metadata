class RemoveOAPermissionsFromPublication < ActiveRecord::Migration[6.1]
  def change
    remove_column :publications, :licence, :string
    remove_column :publications, :set_statement, :string
    remove_column :publications, :embargo_date, :date
    remove_column :publications, :checked_for_set_statement, :boolean
    remove_column :publications, :checked_for_embargo_date, :boolean
  end
end
