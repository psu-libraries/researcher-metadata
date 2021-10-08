class RemoveScholarsphereTimestampFromAuthorships < ActiveRecord::Migration[5.2]
  def change
    remove_column :authorships, :scholarsphere_uploaded_at, :datetime
  end
end
