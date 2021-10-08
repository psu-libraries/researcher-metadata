# frozen_string_literal: true

class AddOpenAccessNotificationTimestampToAuthorships < ActiveRecord::Migration[5.2]
  def change
    add_column :authorships, :open_access_notification_sent_at, :datetime
  end
end
