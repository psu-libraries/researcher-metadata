# frozen_string_literal: true

class StatusMapper
  def self.map(status)
    if status.nil?
      status.to_s
    elsif status.casecmp('in press').zero? || status.casecmp('accepted/in press').zero?
      'In Press'
    elsif status.casecmp('published').zero?
      'Published'
    else
      status.to_s
    end
  end
end
