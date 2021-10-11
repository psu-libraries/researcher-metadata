# frozen_string_literal: true

class OrganizationAPIPermission < ApplicationRecord
  belongs_to :api_token, inverse_of: :organization_api_permissions
  belongs_to :organization

  validates :api_token, :organization, presence: true
end
