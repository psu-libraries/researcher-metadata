class AddPermissionsToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :license, :string
    add_column :publications, :embargo_date, :date
    add_column :publications, :set_statement, :string
    add_column :publications, :preferred_version, :string
    add_column :publications, :permissions_last_checked_at, :datetime
  end
end
