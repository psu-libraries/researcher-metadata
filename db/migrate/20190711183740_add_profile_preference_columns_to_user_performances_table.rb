# frozen_string_literal: true

class AddProfilePreferenceColumnsToUserPerformancesTable < ActiveRecord::Migration[5.2]
  def change
    add_column :user_performances, :visible_in_profile, :boolean, default: true
    add_column :user_performances, :position_in_profile, :integer
  end
end
