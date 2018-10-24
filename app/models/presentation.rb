class Presentation < ApplicationRecord
  has_many :presentation_contributions
  has_many :users, through: :presentation_contributions

  validates :activity_insight_identifier, presence: true, uniqueness: true

  scope :visible, -> { where visible: true }

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end

  def label_name
    self.name.presence || self.title.presence || self.id.to_s
  end

  rails_admin do
    object_label_method { :label_name }

    edit do
      field(:visible) { label 'Visible via API?' }
    end
  end
end
