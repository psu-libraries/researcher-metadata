class ChangeNewsFeedItemIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :news_feed_items, :url
    add_index :news_feed_items, [:url, :user_id], unique: true
  end
end
