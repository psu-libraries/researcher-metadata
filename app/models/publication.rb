class Publication < ActiveRecord::Base
  validates :title, presence: true
end
