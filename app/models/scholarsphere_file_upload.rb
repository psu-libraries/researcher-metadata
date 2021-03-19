class ScholarsphereFileUpload < ApplicationRecord
  after_destroy :remove_file!

  belongs_to :work_deposit,
             class_name: :ScholarsphereWorkDeposit,
             foreign_key: :scholarsphere_work_deposit_id

  validates :file, presence: true

  mount_uploader :file, ScholarsphereFileUploader
end
