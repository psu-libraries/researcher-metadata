# frozen_string_literal: true

class AddVisibilityColumnToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :visible_in_profile, :boolean
  end
end
