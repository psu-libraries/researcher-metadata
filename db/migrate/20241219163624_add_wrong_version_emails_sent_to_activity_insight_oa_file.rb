class AddWrongVersionEmailsSentToActivityInsightOAFile < ActiveRecord::Migration[7.2]
  def change
    add_column :activity_insight_oa_files, :wrong_version_emails_sent, :integer
  end
end
