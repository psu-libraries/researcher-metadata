# frozen_string_literal: true

class AddPositionColumnToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :position_in_profile, :integer
  end
end
