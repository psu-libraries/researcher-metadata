# frozen_string_literal: true

class ActivityInsightPublicationExporter < ActivityInsightExporter
  def initialize(publications, target)
    super()
    @publications = publications
    # target should be 'beta' or 'production'
    @target = target
  end

  def export
    logger = Logger.new('log/ai_publication_export.log')
    logger.info "Full publication export to #{target} Activity Insight started at #{DateTime.now}"
    not_exported_ids = []
    publications.each do |publication|
      if publication.ai_import_identifiers.present? || publication.exported_to_activity_insight
        not_exported_ids << publication.id
        next
      end

      response = HTTParty.post webservice_url, body: to_xml(publication),
                                               headers: { 'Content-type' => 'text/xml' }, basic_auth: auth, timeout: 180
      if response.code != 200
        logger.error Nokogiri::XML(response.to_s).text
        logger.error "Publication ID: #{publication.id}"
        not_exported_ids << publication.id
      elsif target == 'production'
        publication.exported_to_activity_insight = true
        publication.save!
      end
    end

    logger.info "Full publication export to #{target} Activity Insight ended at #{DateTime.now}"
    logger.info "Publications not exported to AI: #{not_exported_ids}"
  end

  private

    attr_accessor :publications, :target

    def to_xml(publication)
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.Data do
          publication.users.each do |user|
            next unless user.activity_insight_identifier

            xml.Record('username' => user.webaccess_id) do
              xml.INTELLCONT do
                xml.TITLE_(publication.title, access: 'READ_ONLY')
                xml.TITLE_SECONDARY_(publication.secondary_title, access: 'READ_ONLY')
                case publication.publication_type
                when 'In-house Journal Article'
                  xml.CONTYPE_('Journal Article, In House', access: 'READ_ONLY')
                when /Journal Article/
                  xml.CONTYPE_('Journal Article', access: 'READ_ONLY')
                else
                  xml.CONTYPE_('Other', access: 'READ_ONLY')
                end
                if publication.status == 'Accepted/In press'
                  xml.STATUS_('Accepted', access: 'READ_ONLY')
                else
                  xml.STATUS_(publication.status, access: 'READ_ONLY')
                end
                xml.JOURNAL_NAME_(publication.journal_title, access: 'READ_ONLY')
                xml.VOLUME_(publication.volume, access: 'READ_ONLY')
                if publication.published_on.present?
                  xml.DTY_PUB_(publication.published_on.year, access: 'READ_ONLY')
                  xml.DTM_PUB_(publication.published_on.strftime('%B'), access: 'READ_ONLY')
                  xml.DTD_PUB_(publication.published_on.day, access: 'READ_ONLY')
                end
                xml.ISSUE_(publication.issue, access: 'READ_ONLY')
                xml.EDITION_(publication.edition, access: 'READ_ONLY')
                xml.ABSTRACT_(publication.abstract, access: 'READ_ONLY')
                xml.PAGENUM_(publication.page_range, access: 'READ_ONLY')
                xml.CITATION_COUNT_(publication.total_scopus_citations, access: 'READ_ONLY')
                xml.AUTHORS_ETAL_(publication.authors_et_al, access: 'READ_ONLY')
                xml.WEB_ADDRESS_((publication.preferred_open_access_url || publication.doi || publication.url), access: 'READ_ONLY')
                xml.ISBNISSN_((publication.isbn || publication.issn), access: 'READ_ONLY')
                publication.contributor_names.each do |contributor|
                  xml.INTELLCONT_AUTH do
                    xml.FNAME_(contributor.first_name, access: 'READ_ONLY')
                    xml.MNAME_(contributor.middle_name, access: 'READ_ONLY')
                    xml.LNAME_(contributor.last_name, access: 'READ_ONLY')
                  end
                end
                xml.RMD_ID(publication.id, access: 'READ_ONLY')
              end
            end
          end
        end
      end
      builder.to_xml
    end

    def webservice_url
      case target
      when 'beta'
        'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      when 'production'
        'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      end
    end
end
