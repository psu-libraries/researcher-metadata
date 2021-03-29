class ScholarsphereWorkDeposit < ApplicationRecord
  def self.statuses
    ['Pending', 'Success', 'Failed']
  end

  belongs_to :authorship
  has_many :file_uploads, class_name: :ScholarsphereFileUpload, dependent: :destroy
  has_one :publication, through: :authorship

  validates :status, inclusion: {in: statuses}
  
  accepts_nested_attributes_for :file_uploads
end
