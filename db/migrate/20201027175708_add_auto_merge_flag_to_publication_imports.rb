# frozen_string_literal: true

class AddAutoMergeFlagToPublicationImports < ActiveRecord::Migration[5.2]
  def change
    add_column :publication_imports, :auto_merged, :boolean
  end
end
