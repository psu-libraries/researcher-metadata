class ScholarsphereFileUpload < ApplicationRecord
  belongs_to :authorship

  validates :file, presence: true
end
