class AddUpdatedByUserAtTimestampToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :updated_by_user_at, :datetime
  end
end
