# frozen_string_literal: true

class AddUpdatedByOwnerAtTimestampToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :updated_by_owner_at, :timestamp
  end
end
