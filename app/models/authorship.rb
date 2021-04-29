class Authorship < ApplicationRecord
  belongs_to :user, inverse_of: :authorships
  belongs_to :publication, inverse_of: :authorships
  has_one :waiver, class_name: :InternalPublicationWaiver, inverse_of: :authorship
  has_many :scholarsphere_work_deposits

  accepts_nested_attributes_for :waiver

  validates :user_id,
    :publication_id,
    :author_number, presence: true

  validates :user_id, uniqueness: {scope: :publication_id}

  delegate :title,
           :abstract,
           :doi,
           :published_by,
           :year,
           :preferred_open_access_url,
           :scholarsphere_upload_pending?,
           :scholarsphere_upload_failed?,
           :open_access_waived?,
           :no_open_access_information?,
           :is_journal_article?,
           :published_on,
           :secondary_title,
           :preferred_publisher_name,
           to: :publication,
           prefix: false
  delegate :webaccess_id, to: :user, prefix: true

  def description
    "##{id} (#{user.name} - #{publication.title})"
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
      sort_by(:scholarsphere_uploaded_at)
      field(:id)
      field(:publication)
      field(:user)
      field(:scholarsphere_uploaded_at) do
        sort_reverse false
      end
    end

    edit do
      field(:user) { read_only true }
      field(:publication) { read_only true }
      field(:author_number) { read_only true }
      field(:orcid_resource_identifier)
      field(:waiver)
    end
  end
end
