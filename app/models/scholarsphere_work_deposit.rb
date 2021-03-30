class ScholarsphereWorkDeposit < ApplicationRecord
  def self.statuses
    ['Pending', 'Success', 'Failed']
  end

  def self.rights
    %w{
        https://creativecommons.org/licenses/by/4.0/
        https://creativecommons.org/licenses/by-sa/4.0/
        https://creativecommons.org/licenses/by-nc/4.0/
        https://creativecommons.org/licenses/by-nd/4.0/
        https://creativecommons.org/licenses/by-nc-nd/4.0/
        https://creativecommons.org/licenses/by-nc-sa/4.0/
        http://creativecommons.org/publicdomain/mark/1.0/
        http://creativecommons.org/publicdomain/zero/1.0/
        https://rightsstatements.org/page/InC/1.0/
        http://www.apache.org/licenses/LICENSE-2.0
        https://www.gnu.org/licenses/gpl.html
        https://opensource.org/licenses/MIT
        https://opensource.org/licenses/BSD-3-Clause
    }
  end

  after_initialize :set_status

  belongs_to :authorship
  has_many :file_uploads, class_name: :ScholarsphereFileUpload, dependent: :destroy
  has_one :publication, through: :authorship

  validates :status, inclusion: {in: statuses}
  validates :rights, inclusion: {in: rights}
  validates :title, :description, :published_date, :rights, presence: true
  validate :at_least_one_file_upload
  
  accepts_nested_attributes_for :file_uploads

  def self.new_from_authorship(authorship)
    new(authorship: authorship,
        title: authorship.title,
        description: authorship.abstract,
        published_date: authorship.published_on)
  end

  def record_success(url)
    ActiveRecord::Base.transaction do
      update!(status: 'Success', deposited_at: Time.current)
      file_uploads.destroy_all
      publication.update!(scholarsphere_open_access_url: url)
    end
  end

  def metadata
    {
      title: title,
      description: description,
      published_date: published_date,
      work_type: 'article',
      visibility: 'open',
      rights: rights,
      creators: publication.contributor_names.order('position ASC').map do |cn|
        cn.to_scholarsphere_creator
      end
    }
  end

  private

  def at_least_one_file_upload
    if file_uploads.blank? && status == 'Pending'
      errors[:base] << I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
    end
  end

  def set_status
    self.status = 'Pending' if new_record?
  end
end
