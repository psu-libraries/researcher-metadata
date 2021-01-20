class ActivityInsightPublicationTypeMapOut
  def self.map(string)
    case string
    when 'Academic Journal Article', 'Professional Journal Article', 'Trade Journal Article', 'Journal Article',
        'Abstract', 'Blog', 'Book', 'Conference Proceeding', 'Extension Publication', 'Magazine/Trade Publication',
        'Manuscript', 'Newsletter', 'Newspaper Article'
      string
    when 'In-house Journal Article'
      'Journal Article, In House'
    when 'Chapter'
      'Book Chapter'
    when 'Book/Film/Article Review'
      'Book Review'
    when 'Encyclopedia/Dictionary Entry'
      'Encyclopedia Entry'
    else
      'Other'
    end
  end
end