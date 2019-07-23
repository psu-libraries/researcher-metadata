class UserPerformance < ApplicationRecord
  belongs_to :user, :inverse_of => :user_performances
  belongs_to :performance, :inverse_of => :user_performances

  validates :user_id, :performance_id, :activity_insight_id, presence: true
  validates :activity_insight_id, uniqueness: true

  delegate :title, :location, :start_on, to: :performance, prefix: true
  delegate :webaccess_id, to: :user, prefix: true
end
