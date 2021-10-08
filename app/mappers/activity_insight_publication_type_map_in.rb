# frozen_string_literal: true

class ActivityInsightPublicationTypeMapIn
  def self.map(string)
    case string
    when 'Journal Article', 'Abstract', 'Blog', 'Book', 'Conference Proceeding',
        'Extension Publication', 'Magazine/Trade Publication', 'Manuscript', 'Newsletter', 'Newspaper Article'
      string
    when 'Journal Article, In House'
      'In-house Journal Article'
    when 'Book Chapter'
      'Chapter'
    when 'Book Review'
      'Book/Film/Article Review'
    when 'Encyclopedia Entry'
      'Encyclopedia/Dictionary Entry'
    else
      'Other'
    end
  end
end
