class APIToken < ApplicationRecord
  before_create :set_token

  def increment_request_count
    update_column(:total_requests, total_requests + 1)
    update_column(:last_used_at, Time.current)
  end

  rails_admin do
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
  end

  private

  def set_token
    self.token ||= SecureRandom.hex(48)
  end
end
