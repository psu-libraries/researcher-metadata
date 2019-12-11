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
           to: :publication,
           prefix: false
  delegate :webaccess_id, to: :user, prefix: true

  def description
    "Authorship ##{id}"
  end

  rails_admin do
    object_label_method { :description }
  end
end
