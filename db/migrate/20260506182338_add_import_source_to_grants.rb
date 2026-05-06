class AddImportSourceToGrants < ActiveRecord::Migration[7.2]
  def change
    add_column :grants, :import_source, :string
    add_column :research_funds, :import_source, :string
    add_column :researcher_funds, :import_source, :string
  end
end
