class Performance < ApplicationRecord
  has_many :user_performances, :inverse_of => :performance, dependent: :destroy
  has_many :users, through: :user_performances
  has_many :imports, class_name: :PerformanceImport

  validates :title, presence: true

  scope :visible, -> { where visible: true }

  rails_admin do
    edit do
      field(:visible) { label 'Visible via API?'}
    end
  end
end
