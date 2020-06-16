class AddOpenAccessNotificationTimestampToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :open_access_notification_sent_at, :datetime
  end
end
