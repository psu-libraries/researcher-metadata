class Presentation < ApplicationRecord
  scope :visible, -> { where visible: true }

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end
end
