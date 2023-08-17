class AddPermissionsMetadataCheckFlagsToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :checked_for_set_statement, :boolean
    add_column :publications, :checked_for_embargo_date, :boolean
  end
end
