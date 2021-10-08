class AddOrcidResourceIdentifierToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :orcid_resource_identifier, :string
  end
end
