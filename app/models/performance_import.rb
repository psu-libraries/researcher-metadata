class PerformanceImport < ApplicationRecord
  belongs_to :performance        

  validates :performance, :activity_insight_id, presence: true
end
