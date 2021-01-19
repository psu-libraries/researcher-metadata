require 'component/component_spec_helper'

describe ActivityInsightPublicationTypeMapOut do
  describe '#map' do
    it "keeps 'Academic Journal Article', 'Professional Journal Article', and 'Trade Journal Article' as is" do
      expect(described_class.map('Academic Journal Article')).to eq 'Academic Journal Article'
      expect(described_class.map('Professional Journal Article')).to eq 'Professional Journal Article'
      expect(described_class.map('Trade Journal Article')).to eq 'Trade Journal Article'
    end

    it "converts 'In-house Journal Article' to 'Journal Article, In House'" do
      expect(described_class.map('In-house Journal Article')).to eq 'Journal Article, In House'
    end

    it "keeps 'Abstract' as 'Abstract'" do
      expect(described_class.map('Abstract')).to eq 'Abstract'
    end

    it "keeps 'Blog' as 'Blog'" do
      expect(described_class.map('Blog')).to eq 'Blog'
    end

    it "keeps 'Book' as 'Book'" do
      expect(described_class.map('Book')).to eq 'Book'
    end

    it "converts 'Book/Film/Article Review' to 'Book Review'" do
      expect(described_class.map('Book/Film/Article Review')).to eq 'Book Review'
    end

    it "converts 'Chapter' to 'Book Chapter'" do
      expect(described_class.map('Chapter')).to eq 'Book Chapter'
    end

    it "keeps 'Conference Proceeding' as 'Conference Proceeding'" do
      expect(described_class.map('Conference Proceeding')).to eq 'Conference Proceeding'
    end

    it "converts 'Encyclopedia/Dictionary Entry' to 'Encyclopedia Entry'" do
      expect(described_class.map('Encyclopedia/Dictionary Entry')).to eq 'Encyclopedia Entry'
    end

    it "keeps 'Extension Publication' as 'Extension Publication'" do
      expect(described_class.map('Extension Publication')).to eq 'Extension Publication'
    end

    it "keeps 'Magazine/Trade Publication' as 'Magazine/Trade Publication'" do
      expect(described_class.map('Magazine/Trade Publication')).to eq 'Magazine/Trade Publication'
    end

    it "keeps 'Manuscript' as 'Manuscript'" do
      expect(described_class.map('Manuscript')).to eq 'Manuscript'
    end

    it "keeps 'Newsletter' as 'Newsletter'" do
      expect(described_class.map('Newsletter')).to eq 'Newsletter'
    end

    it "keeps 'Newspaper Article' as 'Newspaper Article'" do
      expect(described_class.map('Newspaper Article')).to eq 'Newspaper Article'
    end

    it "converts any other string to 'Other'" do
      expect(described_class.map('Other')).to eq 'Other'
      expect(described_class.map('Patent')).to eq 'Other'
      expect(described_class.map('Commissioned Report')).to eq 'Other'
      expect(described_class.map('Editorial')).to eq 'Other'
    end
  end
end
