class AddEditedManuallyToJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :journals, :edited_manually, :boolean, default: false, null: false
  end
end
