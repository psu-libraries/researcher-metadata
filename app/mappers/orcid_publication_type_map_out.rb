# frozen_string_literal: true

class OrcidPublicationTypeMapOut
  def self.map(string)
    case string
    when 'Academic Journal Article', 'In-house Journal Article', 'Professional Journal Article',
        'Trade Journal Article', 'Journal Article', 'Review Article'
      'journal-article'
    when 'Blog'
      'online-resource'
    when 'Book'
      'book'
    when 'Chapter'
      'book-chapter'
    when 'Book/Film/Article Review'
      'book-review'
    when 'Conference Proceeding'
      'conference-paper'
    when 'Encyclopedia/Dictionary Entry'
      'encyclopedia-entry'
    when 'Magazine/Trade Publication'
      'magazine article'
    when 'Newsletter'
      'newsletter-article'
    when 'Newspaper Article'
      'newspaper-article'
    when 'Comment/Debate'
      'lecture-speech'
    when 'Commissioned Report'
      'report'
    when 'Foreword/Postscript'
      'annotation'
    when 'Patent'
      'patent'
    when 'Poster'
      'conference-poster'
    when 'Working Paper'
      'working-paper'
    when 'Other', 'Abstract', 'Extension Publication', 'Manuscript', 'Digital or Visual Product', 'Editorial',
        'Letter', 'Paper', 'Scholarly Edition', 'Short Survey'
      'other'
    end
  end
end
