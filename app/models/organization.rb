class Organization < ApplicationRecord
  belongs_to :parent, class_name: :Organization, optional: true
  belongs_to :owner, class_name: :User, optional: true
  has_many :children, class_name: :Organization, foreign_key: :parent_id
  has_many :user_organization_memberships, inverse_of: :organization
  has_many :users, through: :user_organization_memberships

  validates :name, presence: true

  scope :visible, -> { where(visible: true) }

  def publications
    user_organization_memberships.map do |m|
      Publication.
        visible.
        joins(:authorships).
        where('authorships.user_id = ? AND published_on >= ? AND published_on <= ?',
              m.user_id,
              m.started_on,
              m.ended_on || 1.day.from_now,)
    end.flatten.uniq
  end
end
