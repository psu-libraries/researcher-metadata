class CreateOaNotificationSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :oa_notification_settings do |t|
      t.integer :email_cap
      t.boolean :is_active

      t.timestamps
    end
  end
end
