# frozen_string_literal: true

class AddProfilePreferenceColumnsToPresentationConributions < ActiveRecord::Migration[5.2]
  def change
    add_column :presentation_contributions, :visible_in_profile, :boolean, default: true
    add_column :presentation_contributions, :position_in_profile, :integer
  end
end
