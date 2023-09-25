class RenameEmailLastSentAtInPublications < ActiveRecord::Migration[6.1]
  def change
    rename_column :publications, :email_last_sent_at, :wrong_oa_version_notification_sent_at
  end
end
