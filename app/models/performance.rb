# frozen_string_literal: true

class Performance < ApplicationRecord
  has_many :user_performances, inverse_of: :performance, dependent: :destroy
  has_many :users, through: :user_performances
  has_many :performance_screenings

  validates :title, :activity_insight_id, presence: true

  scope :visible, -> { where visible: true }

  rails_admin do
    edit do
      field(:visible) { label 'Visible via API?' }
    end
  end
end
