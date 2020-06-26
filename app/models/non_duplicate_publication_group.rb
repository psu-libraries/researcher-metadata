class NonDuplicatePublicationGroup < ApplicationRecord
  has_many :publications, inverse_of: :non_duplicate_group
end
