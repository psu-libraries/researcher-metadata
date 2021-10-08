# frozen_string_literal: true

class PresentationContribution < ApplicationRecord
  belongs_to :user, inverse_of: :presentation_contributions
  belongs_to :presentation, inverse_of: :presentation_contributions

  validates :user_id, :presentation_id, presence: true

  delegate :label, :organization, :location, to: :presentation, prefix: true
  delegate :webaccess_id, to: :user, prefix: true
end
