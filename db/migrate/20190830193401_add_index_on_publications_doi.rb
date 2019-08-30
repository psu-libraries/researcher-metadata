class AddIndexOnPublicationsDOI < ActiveRecord::Migration[5.2]
  def change
    add_index :publications, :doi
  end
end
