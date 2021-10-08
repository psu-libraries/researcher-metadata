# frozen_string_literal: true

class OAIRepoRecord
  def initialize(record)
    @record = record
  end

  def title
    attribute('title')
  end

  def description
    attribute('description')
  end

  def date
    record.header.datestamp
  end

  def publisher
    attribute('publisher')
  end

  def url
    attribute('identifier')
  end

  def creators
    metadata.xpath('//metadata//oai_dc:dc//dc:creator', *namespace).map { |c| creator_type.new(c.text) }
  end

  def identifier
    record.header.identifier
  end

  def source
    metadata.xpath('//metadata//oai_dc:dc//dc:source', *namespace)[0].text
  end

  def any_user_matches?
    !!creators.find { |c| c.user_match || c.ambiguous_user_matches.any? }
  end

  private

    attr_reader :record

    def metadata
      Nokogiri::XML(@record.metadata)
    end

    def attribute(name)
      metadata.xpath("//metadata//oai_dc:dc//dc:#{name}", *namespace).text
    end

    def namespace
      ['oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'dc' => 'http://purl.org/dc/elements/1.1/']
    end

    def creator_type
      raise NotImplementedError.new('This method should be defined in a subclass')
    end
end
