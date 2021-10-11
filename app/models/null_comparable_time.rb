# frozen_string_literal: true

class NullComparableTime < Time
  def <=>(other)
    return 1 if other.is_a? NullTime

    super
  end
end
