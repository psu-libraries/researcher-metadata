# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightPublicationTypeMapIn do
  describe '#map' do
    it "keeps 'Abstract' as 'Abstract'" do
      expect(described_class.map('Abstract')).to eq 'Abstract'
    end

    it "keeps 'Blog' as 'Blog'" do
      expect(described_class.map('Blog')).to eq 'Blog'
    end

    it "keeps 'Book' as 'Book'" do
      expect(described_class.map('Book')).to eq 'Book'
    end

    it "converts 'Book Review' to 'Book/Film/Article Review'" do
      expect(described_class.map('Book Review')).to eq 'Book/Film/Article Review'
    end

    it "converts 'Book Chapter' to 'Chapter'" do
      expect(described_class.map('Book Chapter')).to eq 'Chapter'
    end

    it "keeps 'Conference Proceeding' as 'Conference Proceeding'" do
      expect(described_class.map('Conference Proceeding')).to eq 'Conference Proceeding'
    end

    it "converts 'Encyclopedia Entry' to 'Encyclopedia/Dictionary Entry'" do
      expect(described_class.map('Encyclopedia Entry')).to eq 'Encyclopedia/Dictionary Entry'
    end

    it "keeps 'Extension Publication' as 'Extension Publication'" do
      expect(described_class.map('Extension Publication')).to eq 'Extension Publication'
    end

    it "keeps 'Magazine/Trade Publication' as 'Magazine/Trade Publication'" do
      expect(described_class.map('Magazine/Trade Publication')).to eq 'Magazine/Trade Publication'
    end

    it "keeps 'Journal Article' as 'Journal Article'" do
      expect(described_class.map('Journal Article')).to eq 'Journal Article'
    end

    it "converts 'Journal Article, In House' to 'In-house Journal Article'" do
      expect(described_class.map('Journal Article, In House')).to eq 'In-house Journal Article'
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
      expect(described_class.map(nil)).to eq 'Other'
      expect(described_class.map('')).to eq 'Other'
      expect(described_class.map('Other')).to eq 'Other'
      expect(described_class.map('Some other type')).to eq 'Other'
    end
  end
end
