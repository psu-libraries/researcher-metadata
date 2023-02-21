class AddOAStatusTimestampToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :oa_status_last_checked_at, :datetime
  end
end
