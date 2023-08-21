class AddScholarsphereOpenAccessURLToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :scholarsphere_open_access_url, :text
  end
end
