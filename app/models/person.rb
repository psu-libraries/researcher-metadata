class Person < ActiveRecord::Base
  has_one :user
  has_many :authorships
  has_many :publications, through: :authorships
  validates :first_name, :last_name, presence: true
end
