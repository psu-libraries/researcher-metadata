# frozen_string_literal: true

class NullUser
  include NullObjectPattern

  def deputies
    []
  end
  alias :available_deputies :deputies
end
