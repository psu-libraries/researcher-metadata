class CreateOANotificationSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :oa_notification_settings do |t|
      t.integer   :singleton_guard
      t.integer :email_cap
      t.boolean :is_active

      t.timestamps
    end

    add_index(:oa_notification_settings, :singleton_guard, :unique => true)
  end
end
