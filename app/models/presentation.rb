class Presentation < ApplicationRecord
  has_many :presentation_contributions
  has_many :users, through: :presentation_contributions

  validates :activity_insight_identifier, presence: true, uniqueness: true

  scope :visible, -> { where visible: true }

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end

  def label_name
    label || id.to_s
  end

  def label
    l = name.to_s
    l += ' - ' if name.present? && title.present?
    l += title.to_s if title.present?
    l.presence
  end

  rails_admin do
    object_label_method { :label_name }

    edit do
      field(:visible) { label 'Visible via API?' }
    end
  end
end
