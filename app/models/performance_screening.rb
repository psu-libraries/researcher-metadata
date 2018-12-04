class PerformanceScreening < ApplicationRecord
  belongs_to :performance

  validates :performance, presence: true
end
