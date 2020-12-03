class Journal < ApplicationRecord
  belongs_to :publisher, inverse_of: :journals
end
