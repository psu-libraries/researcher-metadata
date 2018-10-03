class NewsFeedItem < ApplicationRecord
  belongs_to :user

  validates :title, :url, :description, :pubdate, presence: true
end
