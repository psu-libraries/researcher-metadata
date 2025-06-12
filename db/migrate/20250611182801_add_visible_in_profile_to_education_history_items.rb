class AddVisibleInProfileToEducationHistoryItems < ActiveRecord::Migration[7.2]
  def change
    add_column :education_history_items, :visible_in_profile, :boolean, default: true, null: false
  end
end
