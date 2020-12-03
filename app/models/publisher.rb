class Publisher < ApplicationRecord
  has_many :journals, inverse_of: :publisher
end
