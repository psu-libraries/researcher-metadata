require 'component/component_spec_helper'

describe PurePublicationTypeMapIn do
  describe '#map' do
    it "converts 'Meeting Abstract' or 'Abstract' to 'Abstract'" do
      expect(described_class.map('Abstract')).to eq 'Abstract'
      expect(described_class.map('Meeting Abstract')).to eq 'Abstract'
    end

    it "converts 'Article' to 'Academic Journal Article'" do
      expect(described_class.map('Article')).to eq 'Academic Journal Article'
    end

    it "keeps 'Book' as 'Book'" do
      expect(described_class.map('Book')).to eq 'Book'
    end

    it "converts 'Book/Film/Article review' to 'Book/Film/Article Review'" do
      expect(described_class.map('Book/Film/Article review')).to eq 'Book/Film/Article Review'
    end

    it "converts 'Chapter' and 'Chapter (peer-reviewed)' to 'Chapter'" do
      expect(described_class.map('Chapter')).to eq 'Chapter'
      expect(described_class.map('Chapter (peer-reviewed)')).to eq 'Chapter'
    end

    it "converts 'Comment/debate' to 'Comment/Debate'" do
      expect(described_class.map('Comment/debate')).to eq 'Comment/Debate'
    end

    it "converts 'Commissioned report' to 'Commissioned Report'" do
      expect(described_class.map('Commissioned report')).to eq 'Commissioned Report'
    end

    it "converts 'Conference contribution' and 'Conference article' to 'Conference Proceeding'" do
      expect(described_class.map('Conference contribution')).to eq 'Conference Proceeding'
      expect(described_class.map('Conference article')).to eq 'Conference Proceeding'
    end

    it "converts 'Digital or Visual Products' to 'Digital or Visual Product'" do
      expect(described_class.map('Digital or Visual Products')).to eq 'Digital or Visual Product'
    end

    it "keeps 'Editorial' as 'Editorial'" do
      expect(described_class.map('Editorial')).to eq 'Editorial'
    end

    it "converts 'Entry for Encyclopedia/dictionary' to 'Encyclopedia/Dictionary Entry'" do
      expect(described_class.map('Entry for Encyclopedia/dictionary')).to eq 'Encyclopedia/Dictionary Entry'
    end

    it "converts 'Foreword/postscript' to 'Foreword/Postscript'" do
      expect(described_class.map('Foreword/postscript')).to eq 'Foreword/Postscript'
    end

    it "keeps 'Letter' as 'Letter'" do
      expect(described_class.map('Letter')).to eq 'Letter'
    end

    it "keeps 'Paper' as 'Paper'" do
      expect(described_class.map('Paper')).to eq 'Paper'
    end

    it "keeps 'Patent' as 'Patent'" do
      expect(described_class.map('Patent')).to eq 'Patent'
    end

    it "keeps 'Poster' as 'Poster'" do
      expect(described_class.map('Poster')).to eq 'Poster'
    end

    it "keeps 'Review Article' as 'Review Article'" do
      expect(described_class.map('Review Article')).to eq 'Review Article'
    end

    it "converts 'Scholarly edition' to 'Scholarly Edition'" do
      expect(described_class.map('Scholarly edition')).to eq 'Scholarly Edition'
    end

    it "converts 'Short survey' to 'Short Survey'" do
      expect(described_class.map('Short survey')).to eq 'Short Survey'
    end

    it "converts 'Working paper' to 'Working Paper'" do
      expect(described_class.map('Working paper')).to eq 'Working Paper'
    end

    it "converts any other string to 'Other'" do
      expect(described_class.map('Other')).to eq 'Other'
      expect(described_class.map('Other contribution')).to eq 'Other'
      expect(described_class.map('rndu*2v2d 8KS dsan^@vf')).to eq 'Other'
    end
  end
end
