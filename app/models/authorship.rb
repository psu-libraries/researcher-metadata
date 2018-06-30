class Authorship < ActiveRecord::Base
  belongs_to :person
  belongs_to :publication
  validates :person_id,
    :publication_id,
    :author_number, presence: true
end
