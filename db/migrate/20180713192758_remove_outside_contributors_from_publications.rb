# frozen_string_literal: true

class RemoveOutsideContributorsFromPublications < ActiveRecord::Migration[5.2]
  def up
    remove_column :publications, :outside_contributors
    remove_column :publication_imports, :outside_contributors
  end

  def down
    add_column :publications, :outside_contributors, :text
    add_column :publication_imports, :outside_contributors, :text
  end
end
