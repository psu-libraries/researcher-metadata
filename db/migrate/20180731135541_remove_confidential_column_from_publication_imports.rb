class RemoveConfidentialColumnFromPublicationImports < ActiveRecord::Migration[5.2]
  def up
    remove_column :publication_imports, :confidential
  end

  def down
    add_column :publication_imports, :confidential, :boolean, default: false
  end
end
