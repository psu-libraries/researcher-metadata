class ScholarsphereFileUpload < ApplicationRecord
  after_destroy :remove_file!

  belongs_to :authorship

  validates :file, presence: true

  mount_uploader :file, ScholarsphereFileUploader
end
