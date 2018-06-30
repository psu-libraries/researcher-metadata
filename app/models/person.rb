class Person < ActiveRecord::Base
  validates :first_name, :last_name, presence: true
end
