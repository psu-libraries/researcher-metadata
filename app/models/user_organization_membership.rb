class UserOrganizationMembership < ApplicationRecord
  def self.import_sources
    ['HR', 'Pure']
  end

  belongs_to :user, inverse_of: :user_organization_memberships
  belongs_to :organization, inverse_of: :user_organization_memberships

  validates :user, :organization, presence: true
  validates :import_source, inclusion: { in: import_sources, allow_nil: true }

  delegate :name, to: :organization, prefix: true

  def name
    "#{user.name} - #{organization.name}"
  end

  rails_admin do
    edit do
      field(:organization)
      field(:user)
      field(:position_title)
      field(:started_on)
      field(:ended_on)

      field(:import_source) { read_only true }
      field(:source_identifier) { read_only true }
      field(:primary) { read_only true }
      field(:updated_by_user_at) { read_only true }
    end
  end
end
