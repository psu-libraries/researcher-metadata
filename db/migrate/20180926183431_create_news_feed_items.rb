class CreateNewsFeedItems < ActiveRecord::Migration[5.2]
  def change
    create_table :news_feed_items do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.text :url, null: false
      t.text :description, null: false
      t.timestamps
    end

    add_index :news_feed_items, :url, unique: true

    add_foreign_key :news_feed_items, :users
  end
end
