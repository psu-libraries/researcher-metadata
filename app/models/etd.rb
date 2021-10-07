class ETD < ApplicationRecord
  def self.submission_types
    [
      'Dissertation',
      'Master Thesis'
    ]
  end

  validates :title,
            :author_first_name,
            :author_last_name,
            :year,
            :url,
            :submission_type,
            :external_identifier,
            :access_level,
            presence: true

  validates :webaccess_id, presence: true, uniqueness: { case_sensitive: false }
  validates :external_identifier, presence: true, uniqueness: true

  validates :submission_type, inclusion: { in: submission_types }

  has_many :committee_memberships, inverse_of: :etd
  has_many :users, through: :committee_memberships

  accepts_nested_attributes_for :committee_memberships, allow_destroy: true

  def author_full_name
    "#{author_first_name} #{author_last_name}"
  end
end
