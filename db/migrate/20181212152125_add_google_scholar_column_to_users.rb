# frozen_string_literal: true

class AddGoogleScholarColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ai_google_scholar, :text
  end
end
