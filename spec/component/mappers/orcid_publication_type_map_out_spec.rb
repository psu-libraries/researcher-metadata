require 'component/component_spec_helper'

describe OrcidPublicationTypeMapOut do
  describe '#map' do
    it "converts 'Academic Journal Article', 'In-house Journal Article', 'Professional Journal Article',
        'Journal Article', 'Review Article' and 'Trade Journal Article' to 'journal-article'" do
      expect(described_class.map('Academic Journal Article')).to eq 'journal-article'
      expect(described_class.map('In-house Journal Article')).to eq 'journal-article'
      expect(described_class.map('Professional Journal Article')).to eq 'journal-article'
      expect(described_class.map('Trade Journal Article')).to eq 'journal-article'
      expect(described_class.map('Journal Article')).to eq 'journal-article'
      expect(described_class.map('Review Article')).to eq 'journal-article'
    end

    it "converts Blog' to 'online-resource'" do
      expect(described_class.map('Blog')).to eq 'online-resource'
    end

    it "converts 'Book' to 'book'" do
      expect(described_class.map('Book')).to eq 'book'
    end

    it "converts 'Book/Film/Article Review' to 'book-review'" do
      expect(described_class.map('Book/Film/Article Review')).to eq 'book-review'
    end

    it "converts 'Chapter' to 'book-chapter'" do
      expect(described_class.map('Chapter')).to eq 'book-chapter'
    end

    it "converts 'Conference Proceeding' to 'conference-paper'" do
      expect(described_class.map('Conference Proceeding')).to eq 'conference-paper'
    end

    it "converts 'Encyclopedia/Dictionary Entry' to 'encyclopedia-entry'" do
      expect(described_class.map('Encyclopedia/Dictionary Entry')).to eq 'encyclopedia-entry'
    end

    it "converts 'Magazine/Trade Publication' to 'magazine article'" do
      expect(described_class.map('Magazine/Trade Publication')).to eq 'magazine article'
    end

    it "converts 'Newsletter' to 'newsletter-article'" do
      expect(described_class.map('Newsletter')).to eq 'newsletter-article'
    end

    it "converts 'Newspaper Article' to 'newspaper-article'" do
      expect(described_class.map('Newspaper Article')).to eq 'newspaper-article'
    end

    it "converts 'Comment/Debate' to 'lecture-speech'" do
      expect(described_class.map('Comment/Debate')).to eq 'lecture-speech'
    end

    it "converts 'Commissioned Report' to 'report'" do
      expect(described_class.map('Commissioned Report')).to eq 'report'
    end

    it "converts 'Foreword/Postscript' to 'annotation'" do
      expect(described_class.map('Foreword/Postscript')).to eq 'annotation'
    end

    it "converts 'Patent' to 'patent'" do
      expect(described_class.map('Patent')).to eq 'patent'
    end

    it "converts 'Poster' to 'conference-poster'" do
      expect(described_class.map('Poster')).to eq 'conference-poster'
    end

    it "converts 'Working Paper' to 'working-paper'" do
      expect(described_class.map('Working Paper')).to eq 'working-paper'
    end
    it "converts any other string to 'Other'" do
      expect(described_class.map('Other')).to eq 'other'
      expect(described_class.map('Manuscript')).to eq 'other'
      expect(described_class.map('Abstract')).to eq 'other'
      expect(described_class.map('Editorial')).to eq 'other'
    end
  end
end
