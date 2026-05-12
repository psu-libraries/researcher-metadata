class AddNullConstraintsToImportSourceColumns < ActiveRecord::Migration[7.2]
  def change
    change_column_null :grants, :import_source, false
    change_column_null :research_funds, :import_source, false
    change_column_null :researcher_funds, :import_source, false
  end
end
