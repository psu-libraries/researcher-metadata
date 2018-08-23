class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def mark_as_updated_by_user
    # It's up to subclasses to implement this if applicable.
  end
end
