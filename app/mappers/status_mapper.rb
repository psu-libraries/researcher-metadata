class StatusMapper
  def self.map(status)
    if status.nil?
      status.to_s
    elsif status.downcase == 'in press' || status.downcase == 'accepted/in press'
      'In Press'
    elsif status.downcase == 'published'
      'Published'
    else
      status.to_s
    end
  end
end
