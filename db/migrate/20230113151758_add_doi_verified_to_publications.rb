class AddDOIVerifiedToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :doi_verified, :boolean
  end
end
