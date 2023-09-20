class AddSuppressOARemindersToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :suppress_oa_reminders, :boolean, default: false
  end
end
