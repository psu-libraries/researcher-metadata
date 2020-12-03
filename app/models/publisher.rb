class Publisher < ApplicationRecord
  has_many :journals, inverse_of: :publisher
  has_many :publications, through: :journals

  rails_admin do
    list do
      field(:id)
      field(:name)
    end
  end
end
