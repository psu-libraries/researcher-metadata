# frozen_string_literal: true

class PresentationContribution < ApplicationRecord
  belongs_to :user, inverse_of: :presentation_contributions
  belongs_to :presentation, inverse_of: :presentation_contributions

  validates :user_id, :presentation_id, presence: true

  delegate :label, :organization, :location, to: :presentation, prefix: true
  delegate :webaccess_id, to: :user, prefix: true

  def self.select_all_style(collection)
    any_visible?(collection) ? 'display: none;' : 'display: inline-block;'
  end

  def self.deselect_all_style(collection)
    any_visible?(collection) ? 'display: inline-block;' : 'display: none;'
  end

  def self.any_visible?(collection)
    collection.any?(&:visible_in_profile)
  end
end
