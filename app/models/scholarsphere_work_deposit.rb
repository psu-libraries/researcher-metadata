# frozen_string_literal: true

class ScholarsphereWorkDeposit < ApplicationRecord
  include DeputyUser

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
    }
  end

  def self.rights_options
    [
      ['Attribution 4.0 International (CC BY 4.0)', 'https://creativecommons.org/licenses/by/4.0/'],
      ['Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)', 'https://creativecommons.org/licenses/by-sa/4.0/'],
      ['Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)', 'https://creativecommons.org/licenses/by-nc/4.0/'],
      ['Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)', 'https://creativecommons.org/licenses/by-nd/4.0/'],
      ['Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)', 'https://creativecommons.org/licenses/by-nc-nd/4.0/'],
      ['Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)', 'https://creativecommons.org/licenses/by-nc-sa/4.0/'],
      ['Public Domain Mark 1.0', 'http://creativecommons.org/publicdomain/mark/1.0/'],
      ['CC0 1.0 Universal', 'http://creativecommons.org/publicdomain/zero/1.0/'],
      ['All rights reserved', 'https://rightsstatements.org/page/InC/1.0/']
    ]
  end

  attribute :deposit_agreement, :boolean

  after_initialize :set_status

  belongs_to :authorship
  has_many :file_uploads, class_name: :ScholarsphereFileUpload, dependent: :destroy
  has_one :publication, through: :authorship

  validates :status, inclusion: { in: statuses }
  validates :rights, inclusion: { in: rights }
  validates :title, :description, :published_date, :rights, presence: true
  validate :at_least_one_file_upload
  validate :agreed_to_deposit_agreement

  accepts_nested_attributes_for :file_uploads

  delegate :title, to: :publication, prefix: true
  delegate :scholarsphere_open_access_url, to: :publication, prefix: false

  def self.new_from_authorship(authorship)
    new(authorship: authorship,
        title: authorship.title,
        description: authorship.abstract,
        published_date: authorship.published_on,
        doi: authorship.doi,
        subtitle: authorship.secondary_title,
        publisher: authorship.preferred_journal_title)
  end

  def record_success(url)
    ActiveRecord::Base.transaction do
      update_columns(status: 'Success', deposited_at: Time.current)
      oal = publication.open_access_locations.find_or_initialize_by(source: Source::SCHOLARSPHERE)
      oal.url = url
      oal.save
    end
    file_uploads.destroy_all
  end

  def record_failure(message)
    update_columns(status: 'Failed', error_message: message)
  end

  def metadata
    base_metadata = {
      title: title,
      description: description,
      published_date: published_date,
      work_type: 'article',
      visibility: 'open',
      rights: rights,
      creators: publication.contributor_names.order('position ASC').map(&:to_scholarsphere_creator)
    }
    base_metadata[:embargoed_until] = embargoed_until if embargoed_until.present?
    base_metadata[:identifier] = [doi] if doi.present?
    base_metadata[:subtitle] = subtitle if subtitle.present?
    base_metadata[:publisher] = [publisher] if publisher.present?
    base_metadata[:publisher_statement] = publisher_statement if publisher_statement.present?
    base_metadata
  end

  def files
    file_uploads.map { |fu| File.new(fu.stored_file_path) }
  end

  private

    def at_least_one_file_upload
      if file_uploads.blank? && status == 'Pending'
        errors[:base] << I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      end
    end

    def agreed_to_deposit_agreement
      if new_record?
        unless deposit_agreement
          errors.add(:deposit_agreement, I18n.t('models.scholarsphere_work_deposit.validation_errors.deposit_agreement'))
        end
      end
    end

    def set_status
      self.status = 'Pending' if new_record?
    end

    rails_admin do
      list do
        field(:id)
        field(:status)
        field(:authorship)
        field(:title)
      end
    end
end
