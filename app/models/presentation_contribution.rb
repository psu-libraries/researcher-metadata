class PresentationContribution < ApplicationRecord
  belongs_to :user, inverse_of: :presentation_contributions
  belongs_to :presentation, inverse_of: :presentation_contributions

  validates :user_id, :presentation_id, presence: true

  delegate :label, to: :presentation, prefix: true
  delegate :organization, to: :presentation, prefix: true
  delegate :location, to: :presentation, prefix: true
end