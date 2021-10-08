# frozen_string_literal: true

class AddOutsideContributorsToPublicationImports < ActiveRecord::Migration[5.2]
  def change
    add_column :publication_imports, :outside_contributors, :text
  end
end
