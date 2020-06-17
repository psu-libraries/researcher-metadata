class Authorship < ApplicationRecord
  belongs_to :user, inverse_of: :authorships
  belongs_to :publication, inverse_of: :authorships
  has_one :waiver, class_name: :InternalPublicationWaiver

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
           :open_access_waived?,
           :no_open_access_information?,
           to: :publication,
           prefix: false
  delegate :webaccess_id, to: :user, prefix: true

  def description
    "Authorship ##{id}"
  end

  def record_open_access_notification
    update_attribute(:open_access_notification_sent_at, Time.current)
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
  end
end
