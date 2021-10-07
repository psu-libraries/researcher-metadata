class StatusMapper
  def self.map(status)
    if status.downcase == 'published'
      'Published'
    elsif status.downcase == 'in press' || status.downcase == 'accepted/in press'
      'In Press'
    else
      status.to_s
    end
  end
end
