class RenamePublisherColumnOnPublicationsToPublisherName < ActiveRecord::Migration[5.2]
  def change
    rename_column :publications, :publisher, :publisher_name
  end
end
