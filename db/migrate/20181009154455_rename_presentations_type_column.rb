class RenamePresentationsTypeColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :presentations, :type, :presentation_type
  end
end
