class AddOpenAccessURLToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :open_access_url, :text
  end
end
