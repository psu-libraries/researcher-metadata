class Performance < ApplicationRecord
  has_many :user_performances, :inverse_of => :performance, dependent: :destroy
  has_many :users, through: :user_performances
  has_many :imports, class_name: :PerformanceImport

  validates :title, :activity_insight_id, presence: true
end
