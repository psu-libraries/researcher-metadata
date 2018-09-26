class NewsFeedItem < ApplicationRecord
  belongs_to :user

  validates :title, :url, :description, presence: true
end
