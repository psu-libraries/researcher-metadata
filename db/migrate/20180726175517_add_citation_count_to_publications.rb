# frozen_string_literal: true

class AddCitationCountToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publication_imports, :citation_count, :integer
    add_column :publications, :citation_count, :integer
  end
end
