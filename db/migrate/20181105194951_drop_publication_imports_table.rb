# frozen_string_literal: true

class DropPublicationImportsTable < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :performance_imports, :performances
    drop_table :performance_imports
  end
end
