class PurePublicationTypeMapIn
  def self.map(string)
    case string
    when 'Book', 'Editorial', 'Letter', 'Paper', 'Patent', 'Poster', 'Review Article'
      string
    when 'Abstract', 'Meeting Abstract'
      'Abstract'
    when 'Article'
      'Academic Journal Article'
    when 'Book/Film/Article review'
      'Book/Film/Article Review'
    when 'Chapter', 'Chapter (peer-reviewed)'
      'Chapter'
    when 'Comment/debate'
      'Comment/Debate'
    when 'Commissioned report'
      'Commissioned Report'
    when 'Conference contribution', 'Conference article'
      'Conference Proceeding'
    when 'Digital or Visual Products'
      'Digital or Visual Product'
    when 'Entry for Encyclopedia/dictionary'
      'Encyclopedia/Dictionary Entry'
    when 'Foreword/postscript'
      'Foreword/Postscript'
    when 'Scholarly edition'
      'Scholarly Edition'
    when 'Short survey'
      'Short Survey'
    when 'Working paper'
      'Working Paper'
    else
      'Other'
    end
  end
end
