class User < ActiveRecord::Base
  belongs_to :person
  validates :webaccess_id, :person_id, presence: true
end
