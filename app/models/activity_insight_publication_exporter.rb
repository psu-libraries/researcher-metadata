class ActivityInsightPublicationExporter

  def initialize(publications, target)
    @publications = publications
    # target should be 'beta or 'production'
    @target = target
  end

  def export
    logger = Logger.new('log/ai_publication_export.log')
    logger.info "Export to #{target} Activity Insight started at #{DateTime.now.to_s}"
    publications.each do |publication|
      next if publication.ai_import_identifiers.present?

      response = HTTParty.post webservice_url, body: to_xml(object),
                               headers: {'Content-type' => 'text/xml'}, basic_auth: auth, timeout: 180
      logger.error Nokogiri::XML(response.to_s).text if response.code != 200
    end
    logger.info "Export to #{target} Activity Insight ended at #{DateTime.now.to_s}"
  end

  private

  attr_accessor :publications, :target

  def auth
    {
      username: Rails.application.config_for(:activity_insight)["username"],
      password: Rails.application.config_for(:activity_insight)["password"]
    }
  end

  def webservice_url
    if target == 'beta'
      'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    elsif target == 'production'
      'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end
  end

  def to_xml(publication)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        publication.users.each do |user|
          next unless user.activity_insight_identifier

          xml.Record('username' => user.webaccess_id) {
            xml.INTELLCONT {
              xml.TITLE_(publication.title, :access => "READ_ONLY")
              xml.TITLE_SECONDARY_(publication.secondary_title, :access => "READ_ONLY")
              xml.CONTYPE_("Journal Article", :access => "READ_ONLY")
              xml.STATUS_(publication.status, :access => "READ_ONLY")
              xml.JOURNAL_NAME_(publication.journal_title, :access => "READ_ONLY")
              xml.VOLUME_(publication.volume, :access => "READ_ONLY")
              if publication.published_on.present?
                xml.DTY_PUB_(publication.published_on.year, :access => "READ_ONLY")
                xml.DTM_PUB_(publication.published_on.strftime("%B"), :access => "READ_ONLY")
                xml.DTD_PUB_(publication.published_on.day, :access => "READ_ONLY")
              end
              xml.ISSUE_(publication.issue, :access => "READ_ONLY")
              xml.EDITION_(publication.edition, :access => "READ_ONLY")
              xml.ABSTRACT_(publication.abstract, :access => "READ_ONLY")
              xml.PAGENUM_(publication.page_range, :access => "READ_ONLY")
              xml.CITATION_COUNT_(publication.total_scopus_citations, :access => "READ_ONLY")
              xml.AUTHORS_ETAL_(publication.authors_et_al, :access => "READ_ONLY")
              xml.WEB_ADDRESS_((publication.preferred_open_access_url || publication.doi || publication.url), :access => "READ_ONLY")
              xml.ISBNISSN_((publication.isbn || publication.issn), :access => "READ_ONLY")
              publication.contributors.each do |contributor|
                xml.INTELLCONT_AUTH {
                  xml.FNAME_(contributor.first_name, :access => "READ_ONLY")
                  xml.MNAME_(contributor.middle_name, :access => "READ_ONLY")
                  xml.LNAME_(contributor.last_name, :access => "READ_ONLY")
                }
              end
            }
          }
        end
      }
    end
    builder.to_xml
  end
end
