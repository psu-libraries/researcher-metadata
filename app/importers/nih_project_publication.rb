# frozen_string_literal: true

class NIHProjectPublication
  class MissingMetadata < RuntimeError; end

  def initialize(publication_data)
    @publication_data = publication_data
  end

  def title
    item_content('Title')
  end

  def year
    date = item_content('PubDate')
    raise MissingMetadata.new('Publication date is missing.') unless date

    date.split.first.to_i
  end

  def doi
    DOISanitizer.new(item_content('DOI')).url
  end

  private

    attr_reader :publication_data

    def parsed_data
      @parsed_data ||= Nokogiri.parse(publication_data)
    end

    def item_content(name)
      parsed_data.at_xpath("//eSummaryResult//DocSum//Item[@Name='#{name}']")&.content
    end
end
