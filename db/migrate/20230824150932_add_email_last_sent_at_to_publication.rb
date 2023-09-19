class AddEmailLastSentAtToPublication < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :email_last_sent_at, :datetime
  end
end
