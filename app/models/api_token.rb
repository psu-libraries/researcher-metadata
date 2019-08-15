class APIToken < ApplicationRecord
  before_create :set_token

  has_many :organization_api_permissions, inverse_of: :api_token
  has_many :organizations, through: :organization_api_permissions
  has_many :users, through: :organizations

  def increment_request_count
    update_column(:total_requests, total_requests + 1)
    update_column(:last_used_at, Time.current)
  end

  rails_admin do
    show do
      field(:token)
      field(:app_name)
      field(:admin_email)
      field(:total_requests)
      field(:last_used_at)
      field(:organizations)
    end

    list do
      field(:id)
      field(:token)
      field(:app_name)
      field(:admin_email)
      field(:total_requests)
      field(:last_used_at)
      field(:created_at)
      field(:updated_at)
    end

    create do
      field(:admin_email)
      field(:app_name)
      field(:organizations)
    end

    edit do
      field(:admin_email)
      field(:app_name)
      field(:organizations)
    end
  end

  private

  def set_token
    self.token ||= SecureRandom.hex(48)
  end
end
