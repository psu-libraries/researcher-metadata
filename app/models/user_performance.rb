class UserPerformance < ApplicationRecord
  belongs_to :user, :inverse_of => :user_performances
  belongs_to :performance, :inverse_of => :user_performances

  validates :user_id, :performance_id, presence: true
  validates :user_id, uniqueness: {scope: :performance_id}
end
