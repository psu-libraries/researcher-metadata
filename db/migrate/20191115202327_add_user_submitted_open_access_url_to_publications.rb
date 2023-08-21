class AddUserSubmittedOpenAccessURLToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :user_submitted_open_access_url, :text
  end
end
