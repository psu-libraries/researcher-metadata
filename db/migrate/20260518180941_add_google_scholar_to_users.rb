# frozen_string_literal: true

class AddGoogleScholarToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :google_scholar_id, :string, null: true
    add_column :users, :google_scholar_h_index, :integer, null: true
    add_column :users, :google_scholar_citation_total, :integer, null: true
    add_column :users, :google_scholar_imported_at, :datetime, null: true

    add_index :users, :google_scholar_id, unique: true
  end
end
