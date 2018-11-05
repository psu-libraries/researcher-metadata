class ChangeNewsFeedItemsPubdateColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :news_feed_items, :pubdate, :published_on
  end
end
