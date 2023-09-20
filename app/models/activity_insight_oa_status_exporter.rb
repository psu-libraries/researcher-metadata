# frozen_string_literal: true

class ActivityInsightOAStatusExporter < ActivityInsightExporter
    def initialize(files, target)
      @files = files
      # target should be 'beta' or 'production'
      @target = target
    end
  
    def export
      logger = Logger.new('log/ai_oa_status_export.log')
      logger.info "Open access status export to #{target} Activity Insight started at #{DateTime.now}"
      not_exported_ids = []
      files.each do |file|
        response = HTTParty.post webservice_url, body: to_xml(file),
                                                 headers: { 'Content-type' => 'text/xml' }, basic_auth: auth, timeout: 180
        if response.code != 200
          logger.error Nokogiri::XML(response.to_s).text
          logger.error "File ID: #{file.id}"
          not_exported_ids << file.id
        elsif target == 'production'
          publication = file.publication
          publication.exported_oa_status_to_activity_insight = true
          publication.save!
        end
      end
  
      logger.info "Open access status export to #{target} Activity Insight ended at #{DateTime.now}"
      logger.info "Files not exported to AI: #{not_exported_ids}"
    end

    private
    
    attr_accessor :files, :target

      def to_xml(file)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.Data do
            user = file.user
            xml.Record('username' => user.webaccess_id) do
              xml.INTELLCONT('id' => file.intellcont_id) do
                xml.POST_FILE('id' => file.post_file_id) do 
                  xml.ACCESIBLE('Already Openly Available')
                end
                xml.RMD_ID(file.publication.id, access: 'READ_ONLY')
              end
            end
          end
        end
        builder.to_xml
      end
  end
  