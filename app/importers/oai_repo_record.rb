class OAIRepoRecord
  def initialize(record, importer)
    @record = record
    @importer = importer
  end

  def title
    attribute('title')
  end

  def description
    attribute('description')
  end

  def text?
    attribute('type') == 'text'
  end

  def date
    Date.parse(attribute('date'))
  end

  def source
    attribute('source')
  end

  def publisher
    attribute('publisher')
  end

  def url1
    metadata.xpath('//metadata//oai_dc:dc//dc:identifier', *namespace)[0].text
  end

  def url2
    metadata.xpath('//metadata//oai_dc:dc//dc:identifier', *namespace)[1].text
  end

  def creators
    metadata.xpath('//metadata//oai_dc:dc//dc:creator', *namespace).map { |c| importer.creator_type.new(c.text) }
  end

  def identifier
    record.header.identifier
  end

  def any_user_matches?
    !! creators.detect { |c| c.user_matches.any? || c.ambiguous_user_matches.any? }
  end

  def user_matches
    creators.map { |c| c.user_matches }.flatten
  end

  def ambiguous_user_matches
    creators.map { |c| c.ambiguous_user_matches }.flatten
  end

  def importable?
    text? && any_user_matches?
  end

  private

  attr_reader :record, :importer

  def metadata
    Nokogiri::XML(@record.metadata)
  end

  def attribute(name)
    metadata.xpath("//metadata//oai_dc:dc//dc:#{name}", *namespace).text
  end

  def namespace
    ['oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'dc' => 'http://purl.org/dc/elements/1.1/']
  end
end
