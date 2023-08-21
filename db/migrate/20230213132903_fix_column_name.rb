class FixColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :publications, :license, :licence
  end
end
