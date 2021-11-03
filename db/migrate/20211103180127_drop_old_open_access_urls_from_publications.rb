class DropOldOpenAccessURLsFromPublications < ActiveRecord::Migration[5.2]
  def change
    remove_column :publications, :scholarsphere_open_access_url, :text
    remove_column :publications, :open_access_url, :text
    remove_column :publications, :user_submitted_open_access_url, :text
  end
end
