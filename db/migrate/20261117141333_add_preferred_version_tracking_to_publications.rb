class AddPreferredVersionTrackingToPublications < ActiveRecord::Migration[8.1]
  def change
    add_column :publications, :preferred_version_updated_at, :datetime
    add_column :publications, :preferred_version_updated_by, :string
  end
end
