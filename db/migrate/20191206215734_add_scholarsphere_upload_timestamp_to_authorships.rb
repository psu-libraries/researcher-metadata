class AddScholarsphereUploadTimestampToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :scholarsphere_uploaded_at, :datetime
  end
end
