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
    Date.parse(attribute('date'))
  end

  def publisher
    attribute('publisher')
  end

  def url1
    metadata.xpath('//metadata//oai_dc:dc//dc:identifier', *namespace)[0].text
  end

  def url2
    metadata.xpath('//metadata//oai_dc:dc//dc:identifier', *namespace)[1].try(:text)
  end

  def creators
    metadata.xpath('//metadata//oai_dc:dc//dc:creator', *namespace).map { |c| creator_type.new(c.text) }
  end

  def identifier
    record.header.identifier
  end

  def any_user_matches?
    !! creators.detect { |c| c.user_match || c.ambiguous_user_matches.any? }
  end

  def importable?
    journal_article? && any_user_matches?
  end

  private

  attr_reader :record

  def source
    attribute('source')
  end

  def journal_article?
    raise NotImplementedError.new("This method should be defined in a subclass")
  end

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
    raise NotImplementedError.new("This method should be defined in a subclass")
  end
end
