class Journal < ApplicationRecord
  belongs_to :publisher, inverse_of: :journals
  has_many :publications, inverse_of: :journal
end
