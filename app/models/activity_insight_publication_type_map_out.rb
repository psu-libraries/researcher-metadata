class ActivityInsightPublicationTypeMapOut
  def self.map(string)
    case string
    when 'Abstract'
      'Abstract'
    when 'Blog'
      'Blog'
    when 'Book'
      'Book'
    when 'Chapter'
      'Book Chapter'
    when 'Book/Film/Article Review'
      'Book Review'
    when 'Conference Proceeding'
      'Conference Proceeding'
    when 'Encyclopedia/Dictionary Entry'
      'Encyclopedia Entry'
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
    when 'Comment/Debate', 'Commissioned Report', 'Digital or Visual Product', 'Editorial', 'Foreword/Postscript',
        'Letter', 'Paper', 'Patent', 'Poster', 'Scholarly Edition', 'Short Survey', 'Working Paper', 'Other'
      'Other'
    end
  end
end