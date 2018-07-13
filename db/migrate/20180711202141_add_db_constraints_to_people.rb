class AddDbConstraintsToPeople < ActiveRecord::Migration[5.2]
  def change
    change_column_null :people, :webaccess_id, false
    change_column_default :people, :is_admin, false
  end
end
