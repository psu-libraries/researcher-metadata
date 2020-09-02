class PSULawSchoolPublicationImporter
  attr_reader :repo_records

  def repo
    @repo ||= Fieldhand::Repository.new('https://elibrary.law.psu.edu/do/oai')
  end

  def load_records
    @repo_records = []
    repo.records.each do |r|
      @repo_records.push RepoRecord.new(r.metadata)
    end
  end

  class RepoRecord
    def initialize(xml)
      @xml = xml
    end

    def record
      Nokogiri::XML(@xml)
    end

    def title
      record.xpath('//metadata//oai_dc:dc//dc:title', 'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'dc' => 'http://purl.org/dc/elements/1.1/').text
    end

    def creators
      record.xpath('//metadata//oai_dc:dc//dc:creator', 'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/', 'dc' => 'http://purl.org/dc/elements/1.1/').map { |c| Creator.new(c.text) }
    end

    class Creator
      attr_reader :text

      def initialize(text)
        @text = text
      end

      def last_name
        ln = text.split(',')[0]
        ln.strip if ln
      end

      def first_name
        fn = text.split(',')[1]
        fn.strip.split(' ').first.strip if fn
      end
    end
  end
end
