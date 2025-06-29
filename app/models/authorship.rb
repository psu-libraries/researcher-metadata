# frozen_string_literal: true

class Authorship < ApplicationRecord
  belongs_to :user, inverse_of: :authorships
  belongs_to :publication, inverse_of: :authorships
  has_one :waiver, class_name: :InternalPublicationWaiver, inverse_of: :authorship
  has_many :scholarsphere_work_deposits

  accepts_nested_attributes_for :waiver

  validates :user_id,
            :publication_id,
            :author_number, presence: true

  validates :user_id, uniqueness: { scope: :publication_id }

  delegate :title,
           :secondary_title,
           :publication_type,
           :abstract,
           :doi,
           :published_by,
           :year,
           :preferred_open_access_url,
           :scholarsphere_upload_pending?,
           :scholarsphere_upload_failed?,
           :activity_insight_upload_processing?,
           :open_access_waived?,
           :no_open_access_information?,
           :is_oa_publication?,
           :published_on,
           :secondary_title,
           :preferred_publisher_name,
           :preferred_journal_title,
           :published?,
           :doi_url_path,
           to: :publication,
           prefix: false

  delegate :webaccess_id, :name, to: :user, prefix: true

  scope :unclaimable, -> { where('claimed_by_user IS TRUE OR confirmed IS TRUE') }
  scope :confirmed, -> { where(confirmed: true) }
  scope :claimed_and_unconfirmed, -> { where(confirmed: false, claimed_by_user: true) }

  def description
    if persisted?
      "##{id} (#{user.name} - #{publication.title})"
    end
  end

  def record_open_access_notification
    update_attribute(:open_access_notification_sent_at, Time.current)
  end

  def updated_by_owner
    if updated_by_owner_at
      NullComparableTime.parse(updated_by_owner_at.to_s)
    else
      NullTime.new
    end
  end

  rails_admin do
    object_label_method { :description }

    list do
      scopes [nil, :claimed_and_unconfirmed]
      field(:id)
      field(:user)
      field(:publication)
      field(:confirmed)
      field(:claimed_by_user)
    end

    create do
      field(:user)
      field(:publication)
      field(:author_number)
      field(:confirmed)
    end

    edit do
      field(:user) { read_only true }
      field(:publication) { read_only true }
      field(:claimed_by_user) { read_only true }
      field(:author_number)
      field(:confirmed)
      field(:orcid_resource_identifier)
      field(:waiver)
    end
  end
end
