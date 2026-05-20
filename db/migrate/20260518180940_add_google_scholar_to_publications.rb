# frozen_string_literal: true

class AddGoogleScholarToPublications < ActiveRecord::Migration[7.2]
  def change
    add_column :publications, :google_scholar_citation_count, :integer, null: true
    add_index :publications, :google_scholar_citation_count
  end
end
