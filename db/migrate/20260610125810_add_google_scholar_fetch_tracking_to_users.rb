# frozen_string_literal: true

class AddGoogleScholarFetchTrackingToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :google_scholar_checked_at, :datetime, null: true
    add_column :users, :google_scholar_not_found, :boolean, null: false, default: false
  end
end
