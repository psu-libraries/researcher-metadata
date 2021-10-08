# frozen_string_literal: true

class RenameTypeInPublicationsAndPublicationImports < ActiveRecord::Migration[5.2]
  def change
    rename_column :publications, :type, :publication_type
    rename_column :publication_imports, :type, :publication_type
  end
end
