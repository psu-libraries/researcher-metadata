class Contributor < ApplicationRecord
  belongs_to :publication

  validates :publication, :position, presence: true
  validates :pure_identifier, :activity_insight_identifier, uniqueness: {allow_nil: true}

  def name
    full_name = first_name.to_s
    full_name += ' ' if first_name.present? && middle_name.present?
    full_name += middle_name.to_s if middle_name.present?
    full_name += ' ' if middle_name.present? && last_name.present? || first_name.present? && last_name.present?
    full_name += last_name.to_s if last_name.present?
    full_name
  end
end