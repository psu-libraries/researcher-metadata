class AddOpenAccessStatusToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :open_access_status, :string
  end
end
