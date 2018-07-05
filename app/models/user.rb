class User < ApplicationRecord
  belongs_to :person
  validates :webaccess_id, :person_id, presence: true
end
