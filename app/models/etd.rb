class ETD < ApplicationRecord
  validates :title,
            :author_first_name,
            :author_last_name,
            :webaccess_id,
            :year,
            :url,
            :submission_type,
            :external_identifier,
            :access_level,
            presence: true
end
