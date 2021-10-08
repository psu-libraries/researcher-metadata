# frozen_string_literal: true

class AddPublicationVisibilityFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :show_all_publications, :boolean
  end
end
