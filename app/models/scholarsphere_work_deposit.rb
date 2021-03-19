class ScholarsphereWorkDeposit < ApplicationRecord
  belongs_to :authorship
  has_many :file_uploads, class_name: :ScholarsphereFileUpload, dependent: :destroy

  accepts_nested_attributes_for :file_uploads
end
