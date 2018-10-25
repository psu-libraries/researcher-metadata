class NewsFeedItem < ApplicationRecord
  belongs_to :user

  validates :title, :url, :description, :published_on, presence: true
end
