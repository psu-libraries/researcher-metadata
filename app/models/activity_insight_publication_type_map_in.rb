class ActivityInsightPublicationTypeMapIn
  def self.map(string)
    case string
    when 'Journal Article'
      'Journal Article'
    when 'Journal Article, In House'
      'In-house Journal Article'
    when 'Abstract'
      'Abstract'
    when 'Blog'
      'Blog'
    when 'Book'
      'Book'
    when 'Book Chapter'
      'Chapter'
    when 'Book Review'
      'Book/Film/Article Review'
    when 'Conference Proceeding'
      'Conference Proceeding'
    when 'Encyclopedia Entry'
      'Encyclopedia/Dictionary Entry'
    when 'Extension Publication'
      'Extension Publication'
    when 'Magazine/Trade Publication'
      'Magazine/Trade Publication'
    when 'Manuscript'
      'Manuscript'
    when 'Newsletter'
      'Newsletter'
    when 'Newspaper Article'
      'Newspaper Article'
    else
      'Other'
    end
  end
end