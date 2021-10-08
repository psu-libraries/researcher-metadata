# frozen_string_literal: true

class AddOpenAccessButtonTimestampToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :open_access_button_last_checked_at, :datetime
  end
end
