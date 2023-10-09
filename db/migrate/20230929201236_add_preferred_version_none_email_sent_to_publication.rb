class AddPreferredVersionNoneEmailSentToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :preferred_file_version_none_email_sent, :boolean
  end
end
