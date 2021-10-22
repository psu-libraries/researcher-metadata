class AddUnpaywallTimestampToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :unpaywall_last_checked_at, :datetime
  end
end
