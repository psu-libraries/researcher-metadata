class User < ApplicationRecord
  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: 'user/sessions',
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  belongs_to :person
  validates :webaccess_id, :person_id, presence: true, uniqueness: true
end
