class ScholarsphereWorkDeposit < ApplicationRecord
  def self.statuses
    ['Pending', 'Success', 'Failed']
  end

  belongs_to :authorship
  has_many :file_uploads, class_name: :ScholarsphereFileUpload, dependent: :destroy
  has_one :publication, through: :authorship

  validates :status, inclusion: {in: statuses}
  
  accepts_nested_attributes_for :file_uploads

  def record_success(url)
    ActiveRecord::Base.transaction do
      update!(status: 'Success', deposited_at: Time.current)
      file_uploads.destroy_all
      publication.update!(scholarsphere_open_access_url: url)
    end
  end
end
