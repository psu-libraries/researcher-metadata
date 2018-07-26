class AddConfidentialColumnToPublicationImports < ActiveRecord::Migration[5.2]
  def change
    add_column :publication_imports, :confidential, :boolean, default: false
  end
end
