# frozen_string_literal: true

class AddPubdateColumnToNewsFeedItems < ActiveRecord::Migration[5.2]
  def change
    add_column :news_feed_items, :pubdate, :date, null: false
  end
end
