# frozen_string_literal: true

class NIHProjectPublication
  def initialize(publication_data)
    @publication_data = publication_data
  end

  def title
    item_content('Title')
  end

  def year
    item_content('PubDate').split.first.to_i
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
      parsed_data.at_xpath("//eSummaryResult//DocSum//Item[@Name='#{name}']").content
    end
end
