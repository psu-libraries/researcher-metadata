# frozen_string_literal: true

class StatusMapper
  def self.map(status)
    case (status || '').to_s
    when /^published$/i
      Publication::PUBLISHED_STATUS
    when /^in press$/i
      Publication::IN_PRESS_STATUS
    when /^accepted\/in press$/i
      Publication::IN_PRESS_STATUS
    else
      status.to_s
    end
  end
end
