class APIToken < ApplicationRecord
  before_create :set_token

  private

  def set_token
    self.token ||= SecureRandom.hex(48)
  end
end
