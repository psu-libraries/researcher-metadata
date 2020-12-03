class Journal < ApplicationRecord
  belongs_to :publisher, inverse_of: :journals, optional: true
  has_many :publications, inverse_of: :journal

  rails_admin do
    list do
      field(:id)
      field(:title)
    end
  end
end
