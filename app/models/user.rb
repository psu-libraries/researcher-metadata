class User < ApplicationRecord
  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: 'user/sessions',
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  validates :webaccess_id, presence: true, uniqueness: { case_sensitive: false }
  validates :activity_insight_identifier, uniqueness: { allow_nil: true }
  validates :first_name, :last_name, presence: true

  has_many :authorships
  has_many :publications, through: :authorships

  def admin?
    is_admin
  end
end
