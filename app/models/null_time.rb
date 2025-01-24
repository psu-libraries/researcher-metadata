# frozen_string_literal: true

class NullTime
  include Comparable

  def <=>(other)
    return -1 if other.is_a? Time
    return 0 if other.is_a? NullTime
  end
end
