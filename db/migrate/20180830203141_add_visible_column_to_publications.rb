class AddVisibleColumnToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :visible, :boolean, default: false
  end
end
