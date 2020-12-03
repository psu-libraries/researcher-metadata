class Publisher < ApplicationRecord
  has_many :journals, inverse_of: :publisher
  has_many :publications, through: :journals
end
